# Multistage builds: https://docs.docker.com/develop/develop-images/multistage-build/
#######################
### STAGE 1 - Build ###
#######################
# Let's use a recent ruby image as our base image.
FROM ruby:2.6.3 as builder
# Define some presets we'll use through the rest of the dockerfile.
ARG APP=whale
ARG APP_NUMBER=9999

RUN mkdir -m 0777 /app-build /bundle && \
    addgroup --gid $APP_NUMBER --system $APP && \
    adduser --uid $APP_NUMBER --system $APP --ingroup $APP

USER $APP

WORKDIR /app-build

# moving in the Gemfile, Gemfile.lock, and .ruby-version ensures that Docker caches the bundle install step.
COPY --chown=$APP_NUMBER:$APP_NUMBER Gemfile /app-build/
COPY --chown=$APP_NUMBER:$APP_NUMBER Gemfile.lock /app-build/
COPY --chown=$APP_NUMBER:$APP_NUMBER .ruby-version /app-build/

# bundler work
ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle \
    GEM_PATH=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"
RUN bundle install --jobs 4 --binstubs
RUN find . -iname '*.o' -exec rm {} \; && \
    find . -iname '*.a' -exec rm {} \;

# Copy the app code over. This will typically bust the cache.
COPY --chown=$APP_NUMBER:$APP_NUMBER . /app-build/

######################################
#### STAGE 2 - Copy to container ###
######################################
FROM ruby:2.6.3

# Redefine some presets we'll use through the rest of the dockerfile.
ARG APP=whale
ARG APP_NUMBER=9999
ENV APP_HOME /opt/$APP
ENV LANG C.UTF-8

# recording of the current git commit being built from. (--build-arg GIT_COMMIT=`git rev-parse HEAD`)
ARG GIT_COMMIT=unspecified
LABEL git_commit=$GIT_COMMIT
LABEL application=$APP
# recording of the indicated application version being built from. (--build-arg APP_VERSION=`cat VERSION.txt`)
ARG APP_VERSION=unspecified
LABEL application_version=$APP_VERSION

RUN mkdir -p -m 0777 $APP_HOME/socket && mkdir -p -m 0777 /var/log/$APP/puma/

RUN addgroup --gid $APP_NUMBER --system $APP && \
    adduser --uid $APP_NUMBER --system $APP --ingroup $APP

WORKDIR $APP_HOME

# copy the gems + deps + app from the build container
COPY --chown=$APP_NUMBER:$APP_NUMBER --from=builder /app-build/ $APP_HOME
COPY --chown=$APP_NUMBER:$APP_NUMBER --from=builder /bundle/ /bundle
RUN mkdir -p -m 0744 $APP_HOME/log && \
    mkdir -p -m 1744 $APP_HOME/tmp && \
    chown $APP_NUMBER:$APP_NUMBER $APP_HOME/log $APP_HOME/tmp

# https://github.com/krallin/tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

USER $APP

# set the bundler paths
ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"

ENTRYPOINT ["/tini", "--"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

FROM ruby:3.0.2-alpine

RUN apk update && apk add -u build-base nodejs postgresql-dev yarn

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock package.json yarn.lock ./
RUN bundle install --jobs 4 --binstubs
RUN yarn install --check-files

COPY . .

CMD puma -C config/puma.rb

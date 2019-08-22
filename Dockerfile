FROM ruby:2.5-alpine

RUN apk update && apk add build-base nodejs postgresql-dev yarn

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock package.json yarn.lock ./
RUN bundle install --jobs 4 --binstubs
RUN yarn install

COPY . .

CMD puma -C config/puma.rb

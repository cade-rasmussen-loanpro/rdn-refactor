FROM ruby:3.1.0-alpine

RUN apk add --no-cache \
    build-base \
    icu-dev \
    icu-libs \
    git

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["bundle", "exec", "irb"]

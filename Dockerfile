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

# ---- Non-root user (policy) ----
RUN addgroup -g 10001 -S app && \
    adduser  -u 10001 -S app -G app && \
    chown -R app:app /app

USER app

CMD ["bundle", "exec", "irb"]

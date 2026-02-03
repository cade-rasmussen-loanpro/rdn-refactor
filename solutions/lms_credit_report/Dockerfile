FROM ruby:3.1.0

RUN apt-get update && apt-get install -y \
    build-essential \
    libicu-dev \
    git \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile* ./
RUN bundle install

COPY . .


RUN groupadd -g 10001 app && \
    useradd  -u 10001 -g app -m -s /bin/bash app && \
    chown -R app:app /app

USER app

CMD ["bundle", "exec", "irb"]

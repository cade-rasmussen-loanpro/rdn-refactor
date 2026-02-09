FROM ruby:3.1.0

RUN apt-get update && apt-get install -y \
    build-essential \
    libicu-dev \
    git \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 10001 app && \
    useradd -u 10001 -g app -m -s /bin/bash app && \
    mkdir -p /home/app/bundle && \
    mkdir -p /app/connectors/rdn && \
    chown -R app:app /home/app/bundle /app

ENV BUNDLE_PATH=/home/app/bundle
WORKDIR /app/connectors/rdn

COPY --chown=app:app connectors/rdn/Gemfile* ./

USER app

RUN bundle install

CMD ["bundle", "exec", "irb"]

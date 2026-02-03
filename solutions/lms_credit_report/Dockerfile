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

CMD ["bundle", "exec", "irb"]

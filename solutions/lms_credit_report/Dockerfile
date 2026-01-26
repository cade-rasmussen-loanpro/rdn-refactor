FROM ruby:3.1.0

RUN apt-get update && apt-get install -y \
    build-essential \
    libicu-dev \
    git \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/solutions/lms_credit_report

COPY /solutions/lms_credit_report/Gemfile* ./

RUN bundle install

COPY . /app

CMD ["bundle", "exec", "irb"]
FROM ruby:3.1.0

RUN apt-get update && apt-get install -y \
    build-essential \
    libicu-dev \
    git \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/solutions/ofac_loan_export

COPY /solutions/ofac_loan_export/Gemfile* ./

RUN bundle install

COPY . /app

CMD ["bundle", "exec", "irb"]
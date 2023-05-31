FROM ruby:3.2.2-slim

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    postgresql-client \
    imagemagick \
    git \
    ; \

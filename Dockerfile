# syntax = docker/dockerfile:1

ARG RUBY_VERSION=4.0.2
ARG TARGETPLATFORM

FROM --platform=$TARGETPLATFORM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

LABEL service="happiness"

WORKDIR /rails

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

FROM --platform=$TARGETPLATFORM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git pkg-config ssh \
      libsqlite3-dev libssl-dev libvips libyaml-dev \
      libxml2-dev libxslt1-dev zlib1g-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle lock --add-platform x86_64-linux \
 && bundle config set deployment true \
 && bundle config set without 'development test' \
 && bundle install --jobs 1 --retry 3 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .

RUN bundle exec bootsnap precompile app/ lib/

RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl libsqlite3-0 libvips libjemalloc2 \
      libxml2 libxslt1.1 zlib1g && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

ARG APP_VERSION
ENV APP_VERSION=$APP_VERSION
ARG GIT_REVISION
ENV GIT_REVISION=$GIT_REVISION
ENV LD_PRELOAD="/usr/local/lib/libjemalloc.so"

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80 443
CMD ["./bin/thrust", "./bin/rails", "server"]

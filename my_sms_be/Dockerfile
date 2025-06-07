# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t my_sms_be .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name my_sms_be my_sms_be

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.4
FROM ruby:$RUBY_VERSION-alpine AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apk add --no-cache curl jemalloc

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apk add --no-cache --virtual .build-deps build-base git libyaml pkgconfig

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Copy Mongoid config
COPY config/mongoid.yml ./config/mongoid.yml

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN addgroup -g 1000 -S rails && \
    adduser -u 1000 -S rails -G rails && \
    chown -R rails:rails log tmp
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]

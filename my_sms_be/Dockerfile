# Production Dockerfile
FROM ruby:3.4-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    git \
    yaml-dev

# Set working directory
WORKDIR /app

# Copy Gemfile files
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle config set deployment 'true' && \
    bundle config set without 'development test' && \
    bundle install

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Start the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
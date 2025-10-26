# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"


# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips pkg-config

# Install curl and gpg
RUN apt-get update && apt-get install -y curl gnupg

# Install Node.js and pnpm
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs gcc g++ make && \
    corepack enable && \
    corepack prepare pnpm@10.18.3 --activate

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install node modules
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile    

# Copy application code
COPY . .

COPY config/database.yml.sample config/database.yml

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/
# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Remove node_modules directory
# Can not remove even in .dockerignore because https://github.com/moby/moby/issues/33923#issuecomment-312563142
RUN rm -rf node_modules

RUN sed -i 's/config.force_ssl = true/config.force_ssl = false/g' config/environments/production.rb && \
    sed -i 's/# config.action_mailer.raise_delivery_errors = false/config.action_mailer.raise_delivery_errors = false/g' config/environments/production.rb

RUN sed -i '/gem '\''terser'\''/d' Gemfile && \
    sed -i '/group :development, :test do/a \ \ gem '\''terser'\''' Gemfile
    
# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 libvips && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]

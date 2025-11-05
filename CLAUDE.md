# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Oauth2id** is a production-ready Rails 7.2.2 Single Sign-On (SSO) Portal implementing OAuth2, OpenID Connect, and SAML 2.0 authentication protocols. It's a multi-protocol identity provider suitable for enterprise authentication scenarios.

### Key Technologies
- **Backend**: Ruby 3.0+ on Rails 7.2.2 with Puma
- **Database**: SQLite (default) - configurable to PostgreSQL/MySQL
- **Frontend**: Stimulus controllers + Webpacker 5.4.4 + Bootstrap 4 (Vali Admin theme)
- **Authentication**: Devise + devise-jwt, Doorkeeper, doorkeeper-openid_connect, SAML IdP
- **Package Manager**: pnpm for Node.js dependencies

## Architecture Overview

### MVC Rails Application Structure
```
app/
  controllers/     # Rails controllers
  models/          # ActiveRecord models (User, Doorkeeper::Application, Department, Position, Profile, Jwt)
  views/           # ERB templates
  javascript/      # Stimulus controllers + Webpack packs
  policies/        # Pundit authorization policies
  datatables/      # AJAX data tables for admin interfaces

config/
  routes.rb        # OAuth2/OIDC/SAML routes + user admin routes
  initializers/    # Devise, Doorkeeper, SAML, OpenID Connect configs
  environments/    # Environment-specific configs (development/test/production)
  credentials.yml.enc  # Encrypted credentials (managed via bin/rails credentials:edit)

db/
  migrate/         # Database migrations
  schema.rb        # Current database schema
  seeds.rb         # Seed data

test/
  controllers/     # Controller tests
  models/          # Model tests
  system/          # Capybara system tests
  fixtures/        # Test fixtures
```

### Authentication Architecture

**Multi-Protocol SSO Implementation:**

1. **OAuth2 Provider** (Doorkeeper)
   - Routes: `/oauth/authorize`, `/oauth/token`, `/oauth/authorize`, `/oauth/discovery/keys`
   - Controller glue: `app/controllers/doorkeeper_controller.rb`
   - App model: `app/models/doorkeeper_application.rb`

2. **OpenID Connect** (doorkeeper-openid_connect)
   - Extends OAuth2 with OIDC support
   - Requires `openid` scope minimum
   - Discovery endpoint: `/oauth/discovery/keys`
   - Initializer: `config/initializers/doorkeeper_openid_connect.rb`

3. **SAML 2.0 Identity Provider** (saml_idp)
   - Routes: `/saml/auth`, `/saml/metadata`, `/saml/logout`
   - Controller: `app/controllers/saml_idp_controller.rb`
   - Initializer: `config/initializers/saml_idp.rb`

4. **User Authentication** (Devise)
   - Session-based authentication
   - JWT support via devise-jwt
   - Allowlisted JWT management: `app/models/allowlisted_jwt.rb`

## Common Development Commands

### Initial Setup
```bash
# First-time setup (installs gems, packages, prepares DB, runs seeds)
bin/setup

# Install frontend dependencies
pnpm install --frozen-lockfile
```

### Running the Application
```bash
# Standard Rails server
bin/rails s

# Hot asset reloading (two terminals)
bin/rails s                    # Terminal 1
bin/webpack-dev-server         # Terminal 2

# Or use Foreman (both processes)
foreman start -f Procfile.dev

# Access the application
# Development: http://localhost:3000
# HTTPS local (with puma-dev): https://oauth2id.test
```

### Database Operations
```bash
# Create/migrate DB
bin/rails db:prepare

# Run migrations only
bin/rails db:migrate

# Load seed data
bin/rails db:seed

# Load fixtures
bin/rails db:fixtures:load
```

### Testing
```bash
# Run all tests
bin/rails test:all

# Run specific test file
bin/rails test test/models/user_test.rb

# Run system tests
bin/rails test:system

# Run tests with coverage
COVERAGE=true bin/rails test
```

### Linting & Formatting
```bash
# Ruby linting
bundle exec rubocop

# Fix Ruby linting issues
bundle exec rubocop -A

# JavaScript linting
npx eslint app/javascript/
```

### Asset Management
```bash
# Compile assets for production
bin/rails assets:precompile

# Build Webpack bundles
bin/webpack

# Watch mode for asset compilation
bin/webpack --watch
```

### Docker Operations
```bash
# Build image
docker build --tag ericguo/oauth2id:main .

# Run container
docker run -p 3000:3000 -d --restart always --name oauth2id \
  --env RAILS_MASTER_KEY=YourMasterKey \
  -v ./storage:/rails/storage \
  ericguo/oauth2id:main

# Debug container
docker run --env RAILS_MASTER_KEY=YourMasterKey \
  -v ./storage:/rails/storage \
  -it ericguo/oauth2id:main bash

# Push to registry
docker push ericguo/oauth2id:main
```

### Deployment (Capistrano)
```bash
# Deploy to production
cap production deploy

# Run migrations in production
cap production deploy:migrate
```

### Key Generation

#### OIDC Keys (Required for OpenID Connect)
```bash
openssl genpkey -algorithm RSA -out oauth2id_oidc_private_key.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in oauth2id_oidc_private_key.pem -out oauth2id_oidc_public_key.pem
# Public key available at: /oauth/discovery/keys
```

#### SAML 2.0 Keys
```bash
openssl req -x509 -sha256 -nodes -days 3650 -newkey rsa:2048 \
  -keyout oauth2id_saml_key.key -out oauth2id_saml_cert.crt
# View fingerprint:
openssl x509 -in oauth2id_saml_cert.crt -noout -sha256 -fingerprint
```

#### JWT RS256 Keys
```bash
openssl genpkey -algorithm RSA -out oauth2id_jwt_private_key.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in oauth2id_jwt_private_key.pem -out oauth2id_jwt_public_key.pem
```

## Development Patterns & Conventions

### Rails Conventions
- **Strong Parameters**: Permit attributes in controllers following existing patterns
- **Authorization**: Use Pundit policies in `app/policies/*` with `authorize(record)` and `policy_scope(Model)`
- **Authentication**: Devise handles user auth; JWT via devise-jwt and Warden strategies
- **I18n**: Use `t('key')` instead of literals; add keys to `config/locales/*`
- **Controllers**: Keep lean; offload logic to helpers (`app/helpers/application_helper.rb`) or presenters

### Frontend (Stimulus + Webpacker)
- **Entry pack**: `app/javascript/packs/application.js`
- **Controllers**: Auto-loaded from `app/javascript/controllers/*`
- **Naming**: Controllers named `*_controller.js`, export default class with targets/actions
- **View integration**: Use `data-controller`, `data-action`, `data-target` in ERB
- **Pack loading**: Include via `javascript_pack_tag 'application'` in layouts
- **Auto-loading**: Controllers auto-registered via `definitionsFromContext(require.context('controllers', true, /.js$/))`
- **Polyfills**: `regenerator-runtime` and `@stimulus/polyfills` included globally

### DataTables
- AJAX-powered data tables for admin interfaces
- Keep query/filtering logic in datatable classes under `app/datatables/*`
- Initialize via Ajax, respond with JSON from Datatable classes
- Column mapping kept in the table class

### Security
- **CSRF Protection**: Always enabled for web endpoints
- **API OPTIONS endpoints** (e.g., `/api/me`): Follow existing implementation in `Api::ApplicationController`
- **Credentials**: Use `Rails.application.credentials` or environment variables (never hardcode secrets)

### Background Jobs & Mailers
- Extend `ApplicationJob` and `ApplicationMailer` base classes
- Keep idempotent and side-effect aware

### Testing
- **Framework**: Minitest + Capybara
- **System tests**: Capybara with selenium-webdriver
- **Fixtures**: Prefer fixtures; avoid depending on `db/seeds.rb` for tests
- **CI integration**: `minitest-ci`, `simplecov` in `:ci` gem group
- Layout: `test/*` with fixtures in `test/fixtures/*`

## Key Configuration Files

### Core Application
- `config/application.rb` - Main Rails config (i18n: zh-CN, ActiveStorage/ActionCable/ActionMailbox/ActionText disabled)
- `config/routes.rb` - SSO routes (Doorkeeper, SAML) + admin routes
- `config/database.yml` - Database configuration (SQLite default)

### Authentication & Security
- `config/initializers/devise.rb` - Devise authentication
- `config/initializers/doorkeeper.rb` - OAuth2 provider config
- `config/initializers/doorkeeper_openid_connect.rb` - OIDC config
- `config/initializers/saml_idp.rb` - SAML IdP configuration
- `config/credentials.yml.enc` - Encrypted credentials (managed via `bin/rails credentials:edit`)
- `config/master.key` - Encryption key (NOT in repo!)

### Frontend
- `config/webpacker.yml` - Webpacker configuration
- `package.json` - Node.js dependencies
- `.eslintrc.js` - ESLint configuration

### Deployment
- `Dockerfile` - Multi-stage Docker build
- `Capfile` + `config/deploy.rb` - Capistrano deployment config
- `Procfile.dev` - Foreman process definitions
- `.gitlab-ci.yml` - GitLab CI pipeline
- `.circleci/config.yml` - CircleCI configuration

## Critical Routes & Endpoints

### OAuth2 / OpenID Connect
- Authorization: `GET /oauth/authorize`
- Token: `POST /oauth/token`
- Discovery Keys: `GET /oauth/discovery/keys`
- User info: `GET /oauth/userinfo` (OIDC only)

### SAML 2.0
- Auth: `GET /saml/auth`
- Metadata: `GET /saml/metadata`
- Logout: `GET /saml/logout`

### Admin & Management
- Users: `/users` (Devise-managed)
- Applications: `/oauth/applications` (Doorkeeper)
- JWT Management: `/jwt` endpoints
- Departments/Positions: `/departments`, `/positions`

## Environment Setup Notes

### puma-dev (HTTPS Local Development)
```bash
brew install puma/puma/puma/puma-dev
sudo puma-dev -setup
puma-dev -install
cd ~/.puma-dev
ln -s /path/to/oauth2id oauth2id
# Visit: https://oauth2id.test
```

**Known Issues:**
- For newer MacOS: Add Puma-dev CA to System keychain and restart browser
- For Faraday: Add CA to OpenSSL cert list using openssl-osx-ca
- For httpclient: Copy cert.pem to httpclient gem directory

### Database Migration (MySQL → PostgreSQL)
Use mysql-postgresql-converter:
```bash
mysqldump --set-gtid-purged=OFF --no-tablespaces --compatible=postgresql --default-character-set=utf8 -r db.mysql -u user pass dbname
python ./db_converter.py db.mysql db.psql
psql -d new_db -f db.psql
# Replace ' datetime(6) ' with ' timestamp(6) without time zone '
```

## Important Notes

- **Storage**: SQLite databases stored in `storage/*.sqlite3` (mounted in Docker)
- **UI Theme**: Vali Admin v2.4.1 based on Bootstrap 4, supports IE 11
- **Locales**: Chinese (zh-CN) configured in `config/locales/*`
- **Master Key**: Required for encrypted credentials; never commit `config/master.key`
- **Production Data**: Users may need `u.confirm` to enable sign-in

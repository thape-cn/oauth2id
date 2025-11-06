# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Ruby on Rails 7.1.5** application implementing an **SSO (Single Sign-On) Portal** that supports OAuth2, OpenID Connect (OIDC), and SAML 2.0 authentication protocols. The application acts as a unified identity provider, managing user authentication across multiple client applications.

**Tech Stack:**
- Rails 7.1.5 + Ruby >= 3.0
- **SSO Stack:** Doorkeeper (OAuth2), doorkeeper-openid_connect (OIDC), saml_idp (SAML)
- **Auth:** Devise + devise-jwt for JWT management
- **Frontend:** Webpacker + Stimulus controllers, Vali-admin UI (Bootstrap 4)
- **Database:** SQLite (development), MySQL (production), PostgreSQL (CI)

## Common Development Commands

### Setup & Bootstrapping
```bash
bin/setup                        # Full setup: install gems, yarn, prepare database, load fixtures
bin/rails db:prepare            # Create/migrate database as needed
bin/rails db:fixtures:load      # Load test fixtures into dev database
```

### Running the Application
```bash
bin/rails s                     # Start Rails server on port 3000
bin/webpack-dev-server          # Start Webpacker hot reloader (run in separate terminal)
foreman start -f Procfile.dev   # Run both Rails and Webpack dev servers together
```

### Testing
```bash
bin/rails test                  # Run unit/integration tests
bin/rails test:all             # Run full test suite including system tests (parallel)
bin/rails test test/models/user_test.rb  # Run specific test file
```

### Build & Deploy
```bash
bin/rails assets:precompile     # Compile assets for production
docker build --tag ericguo/oauth2id:main .  # Build Docker image
docker run -p 3000:3000 -d --name oauth2id --env RAILS_MASTER_KEY=YourKey -v ./storage:/rails/storage ericguo/oauth2id:main
```

### Utilities
```bash
bin/rails doorkeeper:db:cleanup                  # Clean expired OAuth tokens/grants
bin/rails gitlab:update_users                    # Sync GitLab users
bin/rails import_export:import_from_csv[path]    # Import users from CSV
bin/rails sync_yxt:all                          # Sync with YXT API
bin/rails sync_nc_uap:all                       # Sync with NC UAP (Oracle database)
yarn install --check-files                      # Sync frontend dependencies
bundle exec rubocop                              # Lint Ruby code (if gem installed)
```

## Architecture Overview

### SSO Implementation

**OAuth2/OIDC Flow:**
- Routes defined via `use_doorkeeper` and `use_doorkeeper_openid_connect` in config/routes.rb:1-3
- Application model: app/models/doorkeeper_application.rb
- JWT allowlisting: app/models/allowlisted_jwt.rb
- Config: config/initializers/doorkeeper_openid_connect.rb (issuer, signing key, claims)
- Key endpoint: `/oauth/authorize` with OPTIONS preflight (config/routes.rb:78)
- Discovery endpoint: `/oauth/discovery/keys`

**SAML Flow:**
- Routes: `/saml/auth`, `/saml/metadata`, `/saml/logout` (config/routes.rb:6-10)
- Controller: app/controllers/saml_idp_controller.rb
- Config: config/initializers/saml_idp.rb
- Supports encrypted assertions (xmlenc gem)

### User Management
- User model: app/models/user.rb
- Devise-based authentication with JWT support
- Employee management: app/controllers/employees_controller.rb
- Department/Position hierarchy: app/models/department.rb, app/models/position.rb
- Policy-based authorization via Pundit: app/policies/*

### Data Architecture
- **Oracle/MySQL Integration:** NC UAP synchronization (lib/tasks/sync_nc_uap.rake)
- **YXT API Integration:** Position synchronization (lib/tasks/sync_yxt.rake, import_yxt_csv.rake)
- **WeChat Integration:** WeChat OAuth and events (app/models/wechat_event_history.rb, lib/tasks/sync_wechat.rake)
- **GitLab Integration:** User status sync (lib/tasks/gitlab.rake)

### Admin Interface
- Datatables for data listing: app/datatables/* (user_datatable.rb, department_datatable.rb, position_datatable.rb)
- Ajax-based tables with filtering and pagination
- UI: Vali-admin theme (Bootstrap 4)

## Key Conventions & Patterns

### Controllers
- **SSO Controllers:** app/controllers/doorkeeper_controller.rb handles OAuth2/OIDC endpoints with OPTIONS preflight support
- **Strong Parameters:** Follow existing patterns in app/controllers/*; permit attributes explicitly
- **CORS:** OPTIONS endpoints must set CORS headers (see app/controllers/doorkeeper_controller.rb:options_authorize)
- **API Endpoints:** Follow pattern in app/controllers/api/application_controller.rb

### Authorization (Pundit)
- Policies live in app/policies/*
- Use `authorize(record)` and `policy_scope(Model)` in controllers
- Common policies: user_policy.rb, profile_policy.rb, application_policy.rb, doorkeeper_application_policy.rb

### Models & Data
- ApplicationRecord base class: app/models/application_record.rb
- Concerns: app/models/concerns/* (shared model logic)
- JWT tokens: AllowlistedJwt model for token management and revocation

### Frontend (Stimulus + Webpacker)
- Entry pack: app/javascript/packs/application.js
- Controllers: app/javascript/controllers/* (auto-registered)
- Naming: `*_controller.js` with Stimulus conventions
- View integration: Use `data-controller`, `data-action`, `data-target` in ERB
- Load JS: `javascript_pack_tag 'application'` in layouts
- Webpacker config: config/webpacker.yml, config/webpack/*

### Background Jobs
- Base class: app/jobs/application_job.rb
- Keep jobs idempotent and side-effect aware

### Testing
- Framework: Minitest with fixtures in test/fixtures/*
- System tests: Capybara + Selenium 4.26.0
- Test structure mirrors app/ structure
- CI integration: simplecov, minitest-ci (group :ci)
- Avoid db/seeds.rb dependencies in tests

## Configuration & Environment

### Credentials
- Use `bin/rails credentials:edit` to manage secrets
- Store Rails master.key securely (not in repo)
- OIDC signing keys generated externally (see README.md:101-129)
- SAML certificates generated externally (README.md:118-122)

### Development HTTPS Setup
- Use puma-dev for local HTTPS: `puma-dev -install` then symlink in ~/.puma-dev
- Visit https://oauth2id.test after setup
- Requires Puma-dev CA certificate trust setup (README.md:60-86)
- HTTP clients (Faraday, httpclient) need CA certificate configured

### Database Configuration
- Development: SQLite (config/database.yml.sample)
- Production: MySQL (see Gemfile:19)
- CI: PostgreSQL (see .circleci/config.yml:29)
- Migrations: db/migrate/*, db/schema.rb

### Important Initializers
- doorkeeper.rb (21KB): OAuth2 provider configuration
- doorkeeper_openid_connect.rb: OIDC settings (issuer, claims, subject types)
- saml_idp.rb: SAML IdP configuration
- devise.rb (15KB): Authentication settings
- omniauth.rb: OAuth provider setup (WeChat, etc.)
- gitlab.rb: GitLab API configuration
- feature_toggles.rb: Feature flags

### Storage
- Persistent storage: mount `./storage:/rails/storage` in Docker
- Stores uploads and database files

## Critical Files to Know

- config/routes.rb - SSO routes (Doorkeeper, SAML), user routes, API routes
- app/controllers/doorkeeper_controller.rb - OAuth2/OIDC endpoint glue
- app/controllers/saml_idp_controller.rb - SAML IdP controller
- app/models/user.rb - User model with Devise + JWT
- app/models/doorkeeper_application.rb - OAuth2 client applications
- app/models/allowlisted_jwt.rb - JWT allowlist and revocation
- config/initializers/doorkeeper_openid_connect.rb - OIDC configuration
- lib/tasks/*.rake - Sync jobs (NC UAP, YXT, GitLab, WeChat)

## Development Notes

- **Rack Version:** gem 'rack', '< 3' required - Rack 3+ breaks HTTP Authorization headers
- **Gems from Git:** Several gems use git sources (devise-jwt, doorkeeper, wechat, saml_idp, yxt-api, omniauth-wechat-oauth2)
- **Asset Pipeline:** Sprockets for app/assets, Webpacker for app/javascript - don't mix
- **I18n:** Use `t('key')` and add to config/locales/* instead of literals
- **Ruby LSP:** ruby-lsp and ruby-lsp-rails gems installed for IDE support

## Common Tasks & Troubleshooting

**Reset Development Environment:**
```bash
bin/rails db:drop db:create db:migrate db:fixtures:load
bin/rails assets:clobber
yarn install --check-files
```

**Generate OIDC/SAML Keys:** See README.md sections "Generate signing key" and "SAML 2.0"

**CI Pipeline:** .circleci/config.yml - runs build, then test (PostgreSQL, parallel 3x, Chrome)

**Production Deployment:** Capistrano + Puma (config/deploy.rb, Capfile) with Docker images

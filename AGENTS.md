# Repository Guidelines

## Setup and development
- On a fresh checkout, copy `config/database.yml.sample` to `config/database.yml` and supply `config/master.key` (or follow `README.md` to create local credentials from `config/credentials.yml.sample`) **before** `bin/setup`; setup does not create these files.
- `bin/setup` installs Ruby/JS dependencies, prepares the database, and loads fixtures into the development database. Use `bin/rails db:prepare` when only database creation/migration is needed.
- Use Yarn 1.22.22 with `yarn.lock`: `yarn install --frozen-lockfile` (or `bin/yarn`). Do not use pnpm despite the presence of `pnpm-lock.yaml`; `package.json` and CI use Yarn.
- If Oracle or SQL Server client libraries are unavailable, export `NO_ORACLE_ENHANCED=true` and `NO_TINY_TDS=true` before Bundler/Rails commands; these flags remove the corresponding native dependencies from the bundle.
- Run both servers with `foreman start -f Procfile.dev`, or run `bin/rails s` and `bin/webpack-dev-server` separately. Full local SSO flows expect `https://oauth2id.test`; use the puma-dev and CA-trust setup in `README.md` rather than assuming localhost will work.

## Verification
- `bin/rails test`: model/controller/integration tests; `bin/rails test:system`: browser tests; `bin/rails test:all`: everything.
- Focus with `bin/rails test test/models/user_test.rb` or one test with `bin/rails test test/models/user_test.rb:12`.
- System tests require Chrome and a matching driver; Selenium Manager resolves them in `test/application_system_test_case.rb`.
- Tests load all fixtures automatically and should not depend on `db/seeds.rb`. SimpleCov is enabled only when `CIRCLECI` is set; there is no `COVERAGE=true` switch.

## Code map and constraints
- `config/routes.rb` wires Doorkeeper OAuth2/OIDC and SAML. Custom OAuth endpoints/CORS glue are in `app/controllers/doorkeeper_controller.rb`; protocol behavior and credentials are configured in `config/initializers/doorkeeper*.rb` and `saml_idp.rb`.
- Keep the asset pipelines separate: Sprockets serves `app/assets/`, while Webpacker serves `app/javascript/` through `packs/application.js`. Stimulus controllers under `app/javascript/controllers/` are auto-registered.
- UI strings use I18n; `config/application.rb` currently allows only the `zh-CN` locale.
- Preserve the Rack `~> 2.2` pin: the `Gemfile` documents a legacy devise-jwt `Authorization` response-header case compatibility requirement. Several auth/protocol gems also come from specific Git forks/branches; do not silently substitute upstream releases.
- Never commit `config/master.key`, local database config, unencrypted credentials, or private signing keys. Docker deployments receive `RAILS_MASTER_KEY` and persist SQLite data by mounting `storage/`.

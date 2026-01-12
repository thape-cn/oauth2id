# Repository Guidelines

## Project Structure & Module Organization
- `app/`: Rails MVC code (controllers, models, views) plus `app/javascript/` for Stimulus controllers and Webpacker packs (`app/javascript/packs/application.js`).
- `config/`: routes, environment settings, and initializers for Devise, Doorkeeper, OIDC, and SAML.
- `db/`: migrations, schema, and seeds; SQLite files live under `storage/` in dev.
- `test/`: Minitest suites (`models/`, `controllers/`, `system/`) and fixtures in `test/fixtures/`.
- `bin/`, `lib/`, `public/`: scripts, shared Ruby modules, and static assets.

## Build, Test, and Development Commands
- `bin/setup`: install gems, set up the database, run seeds.
- `pnpm install --frozen-lockfile`: install frontend dependencies.
- `bin/rails s`: run the Rails server at `http://localhost:3000`.
- `bin/webpack-dev-server`: run the asset dev server (pair with `bin/rails s`).
- `foreman start -f Procfile.dev`: run Rails + Webpacker together.
- `bin/rails db:prepare`: create and migrate the database.
- `bin/rails test:all`: run the full test suite.
- `bin/rails test test/models/user_test.rb`: run a single test file.
- `docker build --tag ericguo/oauth2id:main .`: build the container image.

## Coding Style & Naming Conventions
- Ruby uses standard Rails conventions (2-space indentation, snake_case files, CamelCase classes). Enforced via RuboCop (`.rubocop.yml`, 115-char line limit).
- JavaScript follows ESLint’s recommended rules (`.eslintrc.js`). Stimulus controllers live in `app/javascript/controllers/` and are named `*_controller.js`.
- Prefer `t('key')` for UI strings and add entries under `config/locales/`.

## Testing Guidelines
- Framework: Minitest + Capybara system tests.
- Naming: files end in `*_test.rb`; system tests live in `test/system/`.
- Coverage (optional): `COVERAGE=true bin/rails test`.

## Commit & Pull Request Guidelines
- Commit messages are short and descriptive; recent history uses lowercase with occasional emoji. Match that style and keep subjects action-focused.
- PRs should include a concise description, linked issues, and test results. Add UI screenshots for view changes.

## Security & Configuration Tips
- Secrets live in `config/credentials.yml.enc`; never commit `config/master.key`. For containers, pass `RAILS_MASTER_KEY`.
- OAuth/OIDC/SAML keys are stored outside the repo; see `README.md` for generation commands.

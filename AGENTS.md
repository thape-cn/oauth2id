# Repository Guidelines

## Project Structure & Module Organization
Core Rails code lives in `app/` (controllers, models, policies, datatables, views) with front-end packs in `app/javascript`. Configuration, credentials, and deployment hooks are under `config/`, while migrations and seeds sit in `db/`. Shared helpers belong in `lib/`. Tests mirror the app inside `test/`—`system/` hosts Capybara flows and `fixtures/` supplies sample data. Executables (`bin/rails`, `bin/setup`, webpack shims) stay in `bin/`.

## Build, Test, and Development Commands
- `bin/setup` — install gems, yarn packages, and bootstraps the database.
- `bin/rails s` — start the server on port 3000; run alongside `bin/webpack-dev-server` for hot assets or `foreman start -f Procfile.dev` to launch both.
- `yarn install --check-files` — sync front-end dependencies after pulling main.
- `bin/rails test` / `bin/rails test:all` — run unit/integration suites or the full Minitest matrix including system tests.
- `bin/setup` or `bin/rails db:migrate` — refresh schema before pushing.

## Coding Style & Naming Conventions
Follow Ruby two-space indentation and conventional Rails naming (`CamelCase` classes, snake_case files). `.rubocop.yml` defines strict cops; run `bundle exec rubocop` if the gem is present to catch drift. JavaScript modules target ES2015, linted with the ESLint “recommended” profile via `.eslintrc.js`. Keep Webpacker entry points in `app/javascript/packs/` and prefer kebab-case filenames for Stimulus controllers.

## Testing Guidelines
Minitest backs all suites; create new files as `*_test.rb` beside the code under test. Use fixtures in `test/fixtures/` for deterministic records and trim external calls in Capybara specs. CI enables `simplecov`, so defend new behavior with meaningful assertions before you open a PR. While iterating, run the nearest scope (`bin/rails test test/models/user_test.rb`), then finish with `bin/rails test:all`.

## Commit & Pull Request Guidelines
Recent history favors concise, lower-case summaries (`gem and yarn upgrade`). Keep subjects under 50 characters, imperative when possible, and bundle related changes per commit. PRs should describe intent, list validation commands, link to issues, and attach screenshots or GIFs for UI work. Call out config or migration impacts and confirm secrets stay out of version control.

## Security & Configuration Tips
Rails credentials are required—store `config/master.key` securely and edit secrets with `bin/rails credentials:edit`. Persist uploads via the `/storage` mount when running Docker. Generate OIDC, SAML, and JWT signing keys outside the repo and reference them with environment variables. Double-check OAuth/SAML callback URLs in `config/initializers/` before deploying.

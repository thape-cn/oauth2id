# Repository Guidelines

## Project Structure & Module Organization
Keep Rails domain logic inside `app/`, following conventional directories for controllers, models, policies, datatables, and views. Stimulus controllers and Webpacker packs live in `app/javascript`, while shared helpers and extensions belong in `lib/`. Configuration, environment credentials, and deployment hooks sit under `config/`, and migrations plus seeds live in `db/`. Test fixtures, unit specs, and system flows mirror the app layout within `test/`, with Capybara scenarios in `test/system/`.

## Build, Test, and Development Commands
Run `bin/setup` after cloning or pulling to install Ruby gems, PNPM packages, and migrate the database. Start the Rails server via `bin/rails s`, and pair it with `bin/webpack-dev-server` or `foreman start -f Procfile.dev` for hot asset reloading. Sync front-end dependencies with `pnpm install --frozen-lockfile`. Execute the targeted test suite using `bin/rails test path/to/file_test.rb`, or run the full matrix through `bin/rails test:all`.

## Coding Style & Naming Conventions
Use Ruby two-space indentation and idiomatic Rails naming: `CamelCase` classes, snake_case files, and kebab-case Stimulus controllers in `app/javascript/controllers/`. Follow the cops configured in `.rubocop.yml`; run `bundle exec rubocop` before opening a pull request. JavaScript modules target ES2015 and are linted with the “recommended” ESLint profile defined in `.eslintrc.js`.

## Testing Guidelines
All suites rely on Minitest. Name files `*_test.rb` and colocate them with the code they exercise. Leverage fixtures from `test/fixtures/` for deterministic data and avoid real external calls in Capybara specs. CI enables SimpleCov, so add assertions that defend new behavior and ensure meaningful coverage before merging.

## Commit & Pull Request Guidelines
Adopt concise, lower-case commit subjects under 50 characters (e.g., `normalize oauth redirect`). Group related changes per commit and describe intent in the body if needed. PRs should summarize the change, list validation commands run (such as `bin/rails test:all`), link to any tracked issues, and include screenshots or GIFs for UI updates. Note schema migrations, configuration impacts, and confirm secrets stay out of the repo.

## Security & Configuration Tips
Manage credentials with `bin/rails credentials:edit` and store `config/master.key` securely. Persist uploads via the `/storage` mount when Dockerized. Generate OIDC, SAML, and JWT signing keys outside the repository and reference them through environment variables. Verify OAuth and SAML callback URLs in `config/initializers/` before deploying to new environments.

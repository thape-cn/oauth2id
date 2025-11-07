# Gemini Code Assistant Context

This document provides context for the Gemini code assistant to understand the `oauth2id` project.

## Project Overview

`oauth2id` is a single sign-on (SSO) portal based on the OAuth 2.0 and OpenID Connect (OIDC) protocols. It is a Ruby on Rails application that also supports SAML 2.0. The application serves as a central identity provider.

The frontend uses JavaScript with the Stimulus framework and is managed by Webpacker. The UI is based on the `vali-admin` theme (Bootstrap 4). The project uses `pnpm` as its JavaScript package manager.

The backend is a Ruby on Rails 7.2 application. Key technologies include:
- **Web Server:** Puma
- **Authentication:** Devise and `devise-jwt`
- **Authorization:** Pundit
- **OAuth2/OIDC:** Doorkeeper and `doorkeeper-openid_connect`
- **SAML:** `saml_idp`
- **Database:** The default setup uses SQLite3 for development, but the project is configured to support MySQL and PostgreSQL.
- **Deployment:** Capistrano is used for deployment.

## Building and Running

The project can be run locally for development or as a Docker container.

### Running with Docker

1.  **Build the image:**
    ```bash
    docker build --tag ericguo/oauth2id:main .
    ```
2.  **Run the container:**
    ```bash
    docker run -p 3000:3000 -d --restart always --name oauth2id --env RAILS_MASTER_KEY=<YourMasterKey> -v ./storage:/rails/storage ericguo/oauth2id:main
    ```
    (Replace `<YourMasterKey>` with the actual Rails master key).

### Running Locally (Development)

1.  **Install dependencies:**
    ```bash
    # Install Ruby gems
    bundle install

    # Install Node.js packages
    pnpm install
    ```

2.  **Setup database:**
    ```bash
    # Copy database configuration
    cp config/database.yml.sample config/database.yml

    # Create and migrate the database
    bin/rails db:create
    bin/rails db:migrate
    ```

3.  **Setup credentials:**
    ```bash
    # Create the credentials file if it doesn't exist
    bin/rails credentials:edit
    ```

4.  **Run the development servers:**
    The `Procfile.dev` defines the processes to run. Use a tool like `foreman` or run them in separate terminals.
    ```bash
    # Run Rails server
    bin/rails s -p 3000

    # Run Webpack dev server
    bin/webpack-dev-server
    ```
    The `README.md` also contains instructions for setting up `puma-dev` for local HTTPS development.

## Testing

The test suite is run using Minitest.

1.  **Setup the test environment:**
    ```bash
    # Install dependencies (if not already done)
    bundle install
    pnpm install

    # Copy database configuration
    cp config/database.yml.sample config/database.yml

    # Migrate the test database
    bin/rails db:migrate RAILS_ENV=test
    ```

2.  **Run the tests:**
    The CI configuration uses `bin/rails test:all`.
    ```bash
    bin/rails test:all
    ```

## Development Conventions

*   **Linting:**
    *   Ruby code is linted with RuboCop (see `.rubocop.yml`).
    *   JavaScript code is linted with ESLint (see `.eslintrc.js`).
*   **CI/CD:** The project uses GitLab CI (see `.gitlab-ci.yml`) for running tests and deploying to staging.
*   **Package Management:** Ruby gems are managed with Bundler. JavaScript packages are managed with `pnpm`.

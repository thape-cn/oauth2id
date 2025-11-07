# Project Overview

This project is a Single Sign-On (SSO) portal based on the OAuth2 protocol, built with Ruby on Rails. It also supports SAML and Homeland SSO. The backend is a Rails application, and the frontend uses JavaScript with the Stimulus framework and the vali-admin theme.

## Key Technologies

*   **Backend:** Ruby on Rails
*   **Frontend:** JavaScript, Stimulus, Webpacker, vali-admin
*   **Authentication:** Devise, Doorkeeper (for OAuth2), SAML, JWT
*   **Database:** Primarily uses MySQL in production, with support for SQLite3 and Oracle.
*   **Web Server:** Puma
*   **Deployment:** Docker

# Building and Running

## Docker

The project is designed to be run with Docker.

**Build the Docker image:**

```bash
docker build --tag ericguo/oauth2id:main .
```

**Run the Docker container:**

```bash
docker run -p 3000:3000 -d --restart always --name oauth2id --env RAILS_MASTER_KEY=YourMasterKey -v ./storage:/rails/storage ericguo/oauth2id:main
```

## Development

1.  **Install dependencies:**
    ```bash
    bundle install
    yarn install
    ```

2.  **Set up the database:**
    ```bash
    cp config/database.yml.sample config/database.yml
    bin/rails db:setup
    ```

3.  **Run the tests:**
    ```bash
    bin/rails test:all
    ```

4.  **Start the development server:**
    ```bash
    bin/webpack-dev-server &
    bin/rails s
    ```

# Development Conventions

*   The project uses `rubocop` for Ruby code style enforcement.
*   Frontend assets are managed with `webpacker`.
*   Tests are written with Minitest.
*   The application follows standard Rails conventions for models, views, and controllers.
*   The project uses `pundit` for authorization.

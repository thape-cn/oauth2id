# Restrict OmniAuth to POST requests. Rails CSRF integration is provided by the
# omniauth-rails_csrf_protection gem included in the Gemfile.
OmniAuth.config.allowed_request_methods = [:post]
OmniAuth.config.silence_get_warning = true

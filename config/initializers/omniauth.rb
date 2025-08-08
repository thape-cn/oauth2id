# Allow GET requests for OmniAuth strategies (OmniAuth 2 defaults to POST)
OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.silence_get_warning = true



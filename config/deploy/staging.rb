set :nginx_use_ssl, true

server 'sso-id.com', user: 'deployer', roles: %w{app db web}

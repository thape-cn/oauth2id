set :nginx_use_ssl, true
set :branch, :staging

server 'oauth2id.dev', user: 'deployer', roles: %w{app db web}

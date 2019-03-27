set :nginx_use_ssl, true

server 'oauth2id.dev', user: 'deployer', roles: %w{app db web}

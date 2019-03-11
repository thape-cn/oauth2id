set :nginx_use_ssl, true
set :branch, :thape

server 'thape_sso', user: 'deployer', roles: %w{app db web}

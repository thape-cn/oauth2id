set :nginx_use_ssl, true
set :branch, :thape
set :puma_systemctl_user, :system

server 'thape_sso', user: 'deployer', roles: %w{app db web}

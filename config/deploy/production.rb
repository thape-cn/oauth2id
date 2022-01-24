set :nginx_use_ssl, true
set :rails_env, 'production'
set :branch, :thape
set :puma_service_unit_name, :puma_oauth2id_production
set :puma_systemctl_user, :system

server 'thape_sso', user: 'deployer', roles: %w{app db web}
server 'thape_gitlab', user: 'deployer', roles: %w{app web}

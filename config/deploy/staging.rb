set :nginx_use_ssl, true
set :branch, :main
set :puma_systemctl_user, :system

server 'ericss', user: 'ssoid', roles: %w{app db web}

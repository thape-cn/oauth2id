set :nginx_use_ssl, false
set :branch, :main
set :puma_systemctl_user, :system

server 'ericsg', user: 'ec2-user', roles: %w{app db web}

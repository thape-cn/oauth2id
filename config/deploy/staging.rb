set :nginx_use_ssl, true
set :branch, :main
server 'ericss', user: 'ssoid', roles: %w{app db web}

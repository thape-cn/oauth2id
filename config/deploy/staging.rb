set :nginx_use_ssl, true

server 'ericss', user: 'ssoid', roles: %w{app db web}

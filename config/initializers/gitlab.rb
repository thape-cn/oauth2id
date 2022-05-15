Gitlab.configure do |config|
  config.endpoint       = Rails.application.credentials.gitlab_api_endpoint!
  config.private_token  = Rails.application.credentials.gitlab_admin_private_token!
end

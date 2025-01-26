if Rails.env.production?
  RorVsWild.start(
    api_key: Rails.application.credentials.rorvswild_api_key,
    ignore_requests: %w[
      Doorkeeper::AuthorizationsController#new
      Doorkeeper::OpenidConnect::DiscoveryController#keys
      Doorkeeper::OpenidConnect::DiscoveryController#provider
      Doorkeeper::TokensController#create
      DoorkeeperController#me
      User::SessionsController#new
    ],
    ignore_jobs: [],
    ignore_exceptions: [],
    ignore_plugins: %w[
      Elasticsearch
      Mongo
      Resque
      DelayedJob
    ]
  )
end

if Rails.env.production?
  RorVsWild.start(api_key: Rails.application.credentials.rorvswild_api_key)
end

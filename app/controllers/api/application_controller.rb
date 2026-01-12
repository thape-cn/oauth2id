# frozen_string_literal: true

module API
  class ApplicationController < ActionController::API
    before_action :authenticate_user!

    def user_info
      u = current_user
      profile = u.profile
      if u.user_allowed_applications.find_by(oauth_application_id: 60, enable: true)
        render json: {
          chinese_name: profile&.chinese_name || u.username,
          clerk_code: profile&.clerk_code,
          opencode_api_key: profile&.opencode_api_key || Rails.application.credentials.opencode_api_key,
          kimi_api_key: Rails.application.credentials.kimi_api_key,
          moonshot_api_key: Rails.application.credentials.moonshot_api_key,
          exa_api_key: Rails.application.credentials.exa_api_key,
          deepseek_api_key: Rails.application.credentials.deepseek_api_key,
          email: u.email
        }
      else
        render json: {
          chinese_name: profile&.chinese_name || u.username,
          clerk_code: 'No access',
          opencode_api_key: nil,
          kimi_api_key: nil,
          moonshot_api_key: nil,
          exa_api_key: nil,
          deepseek_api_key: nil,
          email: u.email
        }
      end
    end
  end
end

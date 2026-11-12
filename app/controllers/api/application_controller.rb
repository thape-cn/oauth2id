# frozen_string_literal: true

module API
  class ApplicationController < ActionController::API
    AI_RESEARCH_CENTER_DEPARTMENT_NAME = '天华集团-AI研究中心'

    before_action :authenticate_jwt_user!

    def sigma_agents
      return head :unauthorized unless request.headers['JWT-AUD'] == 'opencode'

      user_info
    end

    def user_info
      u = current_user
      profile = u.profile
      has_access = %w[opencode CAD].include?(request.headers['JWT-AUD']) &&
                   u.user_allowed_applications.exists?(oauth_application_id: 60, enable: true)
      shared_credentials = Rails.application.credentials if has_access
      clerk_code = if has_access
                     profile&.clerk_code
                   elsif profile&.opencode_api_key.present?
                     "🔑#{profile.clerk_code}"
                   else
                     'No Zen'
                   end

      render json: {
        chinese_name: profile&.chinese_name || u.username,
        clerk_code: clerk_code,
        opencode_api_key: profile&.opencode_api_key.presence || shared_credentials&.opencode_api_key,
        kimi_api_keys: kimi_api_keys(profile, shared_credentials),
        hide_agents: hide_agents(u, profile),
        siliconflow_cn_api_key: profile&.siliconflow_cn_api_key.presence || shared_credentials&.siliconflow_cn_api_key,
        moonshot_api_key: profile&.moonshot_api_key.presence || shared_credentials&.moonshot_api_key,
        exa_api_key: profile&.exa_api_key.presence || shared_credentials&.exa_api_key,
        deepseek_api_key: profile&.deepseek_api_key.presence || shared_credentials&.deepseek_api_key,
        cerebras_api_key: profile&.cerebras_api_key.presence || shared_credentials&.cerebras_api_key,
        vipai_api_key: shared_credentials&.vipai_api_key,
        email: u.email
      }
    end

    private

    def authenticate_jwt_user!
      # Warden otherwise accepts the session user before running the JWT strategy.
      strategy = Warden::JWTAuth::Strategy.new(request.env, :user)
      strategy.authenticate! if strategy.valid?
      return head :unauthorized unless strategy.successful?

      warden.set_user(strategy.user, scope: :user, store: false, event: :authentication)
    end

    def kimi_api_keys(profile, shared_credentials)
      [
        profile&.kimi_api_key.presence || shared_credentials&.kimi_api_key_1,
        shared_credentials&.kimi_api_key_3
      ].compact
    end

    def hide_agents(user, profile)
      agents = profile&.hide_agents_names.to_s.split(',').map(&:strip).reject(&:blank?)
      agents |= %w[bid-assistant scheme-assistant] if ai_research_center_user?(user)
      agents
    end

    def ai_research_center_user?(user)
      return false if user.username == 'fengqiaorong'

      main_position = user.position_users.find_by(main_position: true)&.position
      main_position = user.position_users.last&.position if main_position.nil?
      main_position&.department&.name == AI_RESEARCH_CENTER_DEPARTMENT_NAME
    end
  end
end

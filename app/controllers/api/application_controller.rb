# frozen_string_literal: true

module API
  class ApplicationController < ActionController::API
    THAPE_SSO_BEARER_AUDIENCE = 'opencode'
    THAPE_SSO_BEARER_EXP_HOURS = 360_000

    before_action :authenticate_user!

    def user_info
      u = current_user
      profile = u.profile
      has_access = u.user_allowed_applications.find_by(oauth_application_id: 60, enable: true) && (request.headers['JWT-AUD'] == THAPE_SSO_BEARER_AUDIENCE || request.headers['JWT-AUD'] == 'CAD')
      should_issue_thape_sso_token = request_sigma_agents_token?
      thape_sso_bearer_api_key = if should_issue_thape_sso_token
                                   issue_thape_sso_bearer_api_key(u)
                                 end

      if has_access && request.headers['JWT-AUD'] == THAPE_SSO_BEARER_AUDIENCE
        render json: {
          chinese_name: profile&.chinese_name || u.username,
          clerk_code: profile&.clerk_code,
          thape_sso_bearer_api_key: thape_sso_bearer_api_key,
          opencode_api_key: profile&.opencode_api_key.presence || Rails.application.credentials.opencode_api_key,
          kimi_api_key: profile&.kimi_api_key.presence || Rails.application.credentials.kimi_api_key,
          siliconflow_cn_api_key: profile&.siliconflow_cn_api_key.presence || Rails.application.credentials.siliconflow_cn_api_key,
          moonshot_api_key: profile&.moonshot_api_key.presence || Rails.application.credentials.moonshot_api_key,
          exa_api_key: profile&.exa_api_key.presence || Rails.application.credentials.exa_api_key,
          deepseek_api_key: profile&.deepseek_api_key.presence || Rails.application.credentials.deepseek_api_key,
          cerebras_api_key: profile&.cerebras_api_key.presence || Rails.application.credentials.cerebras_api_key,
          email: u.email
        }
      else
        render json: {
          chinese_name: profile&.chinese_name || u.username,
          clerk_code: (profile&.opencode_api_key.present? ? "🔑#{profile&.clerk_code}" : 'No Zen'),
          thape_sso_bearer_api_key: thape_sso_bearer_api_key,
          opencode_api_key: profile&.opencode_api_key.presence,
          kimi_api_key: profile&.kimi_api_key.presence || Rails.application.credentials.kimi_api_key,
          siliconflow_cn_api_key: profile&.siliconflow_cn_api_key.presence,
          moonshot_api_key: profile&.moonshot_api_key.presence || Rails.application.credentials.moonshot_api_key,
          exa_api_key: profile&.exa_api_key.presence,
          deepseek_api_key: profile&.deepseek_api_key.presence || Rails.application.credentials.deepseek_api_key,
          cerebras_api_key: profile&.cerebras_api_key.presence,
          email: u.email
        }
      end
    end

    private

    def issue_thape_sso_bearer_api_key(user)
      exp_seconds = THAPE_SSO_BEARER_EXP_HOURS.hours
      payload = jwt_payload(user, exp_seconds, THAPE_SSO_BEARER_AUDIENCE)
      jwt = Warden::JWTAuth::TokenEncoder.new.call(payload)
      return jwt if user.allowlisted_jwts.create(jti: payload['jti'], aud: payload['aud'], exp: Time.at(payload['exp']))

      nil
    end

    def jwt_payload(user, exp_seconds, aud)
      user_encoder = Warden::JWTAuth::UserEncoder.new
      payload = user_encoder.helper.payload_for_user(user, 'user')
      payload['exp'] = Time.now.to_i + exp_seconds.to_i
      payload['aud'] = aud
      payload
    end

    def request_sigma_agents_token?
      boolean_caster = ActiveModel::Type::Boolean.new
      return true if boolean_caster.cast(request.headers['REQUEST-SIGMA-AGENTS'])
    rescue JSON::ParserError
      false
    end
  end
end

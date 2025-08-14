# frozen_string_literal: true

class User::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def qiye_web
    user = User.from_omniauth(request.env['omniauth.auth'])
    if user.present?
      # Sign in first to trigger JWT dispatch, then perform side effects similar to SessionsController#create
      sign_in user, event: :authentication

      begin
        # Record sign-in history
        user.user_sign_in_histories
            .create(sign_in_at: Time.current,
                    user_agent: request.user_agent, sign_in_ip: request.remote_ip)

        # Collect allowlisted JWT attributes for syncing
        allowlisted_jwts_attributes = user.allowlisted_jwts.last.attributes.except('id', 'user_id')

        # Determine main position
        main_position = user.position_users.find_by(main_position: true)&.position
        main_position = user.position_users.last&.position if main_position.nil?

        # Collect departments
        combine_deparments = user.departments.collect do |department|
          {
            id: department.id,
            name: department.name,
            dept_code: department.dept_code,
            company_name: department.company_name,
            company_code: department.company_code
          }
        end

        # Build user attributes payload
        user_attrs = {
          white_jwts_attrs: allowlisted_jwts_attributes,
          email: user.email,
          windows_sid: user.windows_sid,
          position_title: main_position&.name,
          clerk_code: user.profile&.clerk_code,
          pre_sso_id: user.profile&.pre_sso_id,
          chinese_name: user.profile&.chinese_name,
          job_level: user.profile&.job_level,
          locked_at: user.locked_at&.to_date,
          desk_phone: user.desk_phone,
          departments: combine_deparments
        }
        Rails.logger.debug "user_attrs: #{user_attrs}"
        response1 = HTTP.timeout(4).options(Rails.application.credentials.sync_white_jwts_url1!, json: user_attrs)
        Rails.logger.debug "response1: #{response1}"
      rescue Exception => e
        Rails.logger.debug e
        Rails.logger.debug e.class
      end

      Rails.logger.info("Login via qiye_web username=#{user.username}")
      set_flash_message(:notice, :success, kind: 'qiye_web') if is_navigational_format?
      redirect_to stored_location_for(user) || after_sign_in_path_for(user)
    else
      session['devise.qiye_web_data'] = request.env['omniauth.auth']
      redirect_to new_user_session_url
    end
  end
end

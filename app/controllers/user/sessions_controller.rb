class User::SessionsController < Devise::SessionsController
  protect_from_forgery with: :null_session, if: -> { request.format.json? }
  skip_before_action :verify_signed_out_user, if: -> { request.format.json? }
  respond_to :json, if: -> { request.format.json? }
  layout 'sessions'

  after_action :cors_set_access_control_headers, only: [:create]

  def create
    super do |user|
      user.user_sign_in_histories
          .create(sign_in_at: Time.current,
                  user_agent: request.user_agent, sign_in_ip: request.remote_ip)
      allowlisted_jwts_attributes = user.allowlisted_jwts.last.attributes.except('id', 'user_id')

      main_position = user.position_users.find_by(main_position: true)&.position
      main_position = user.position_users.last&.position if main_position.nil?

      combine_deparments = user.departments.collect do |department|
        {
          id: department.id,
          name: department.name,
          dept_code: department.dept_code,
          company_name: department.company_name,
          company_code: department.company_code
        }
      end

      user_attrs = {
        white_jwts_attrs: allowlisted_jwts_attributes,
        email: user.email,
        position_title: main_position&.name,
        clerk_code: user.profile&.clerk_code,
        chinese_name: user.profile&.chinese_name,
        job_level: user.profile&.job_level,
        locked_at: user.locked_at&.to_date,
        desk_phone: user.desk_phone,
        departments: combine_deparments
      }
      Rails.logger.debug "user_attrs: #{user_attrs}"
      response1 = HTTP.options(Rails.application.credentials.sync_white_jwts_url1!, json: user_attrs)
      Rails.logger.debug response1
      response2 = HTTP.options(Rails.application.credentials.sync_white_jwts_url2!, json: user_attrs)
      Rails.logger.debug response2
    end
  rescue Exception => e
    Rails.logger.debug e
    redirect_to new_user_session_path, alert: "Error creating session"
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = 'https://notes.thape.com.cn'
    headers['Access-Control-Allow-Methods'] = 'POST'
    headers['Access-Control-Allow-Headers'] = 'Accept, Content-Type, Authorization, Origin, Referer, User-Agent, JWT-AUD'
  end
end

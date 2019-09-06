class User::SessionsController < Devise::SessionsController
  protect_from_forgery with: :null_session, if: -> { request.format.json? }
  skip_before_action :verify_signed_out_user, if: -> { request.format.json? }
  respond_to :json, if: -> { request.format.json? }
  layout 'sessions'

  def create
    super do |user|
      user.user_sign_in_histories
          .create(sign_in_at: Time.current,
                  user_agent: request.user_agent, sign_in_ip: request.remote_ip)
      whitelisted_jwts_attributes = user.whitelisted_jwts.last.attributes.except('id', 'user_id')
      sync_white_jwts_attrs = whitelisted_jwts_attributes.merge(email: user.email)

      Rails.logger.debug "sync_white_jwts_attrs: #{sync_white_jwts_attrs}"
      response = HTTP.options(Rails.application.credentials.sync_white_jwts_url!, json: sync_white_jwts_attrs)
      Rails.logger.debug response
    end
  rescue Exception => e
    Rails.logger.debug e
    redirect_to new_user_session_path, alert: "Error creating session"
  end
end

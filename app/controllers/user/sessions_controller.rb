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
    end
  rescue Exception => e
    Rails.logger.debug e
    redirect_to new_user_session_path, alert: "Error creating session"
  end
end

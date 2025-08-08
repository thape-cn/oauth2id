# frozen_string_literal: true

class User::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def qiye_web
    user = User.from_omniauth(request.env['omniauth.auth'])
    if user.present?
      sign_in_and_redirect user, event: :authentication
      Rails.logger.info("Login via qiye_web username=#{user.username}")
      set_flash_message(:notice, :success, kind: 'qiye_web') if is_navigational_format?
    else
      session['devise.qiye_web_data'] = request.env['omniauth.auth']
      redirect_to new_user_session_url
    end
  end
end

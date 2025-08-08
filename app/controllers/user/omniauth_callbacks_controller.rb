# frozen_string_literal: true

class User::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def wechat_qiye
    profile = Profile.from_omniauth(request.env['omniauth.auth'])
    if profile&.user.present?
      sign_in_and_redirect profile.user, event: :authentication
      set_flash_message(:notice, :success, kind: 'wechat') if is_navigational_format?
    else
      session['devise.wechat_data'] = request.env['omniauth.auth']
      redirect_to new_user_session_url
    end
  end
end

class User::RegistrationsController < Devise::RegistrationsController
  before_action :check_signup_allowed, only: %i[new create]
  layout 'sessions', only: %i[new create]


  private

  def sign_up_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  def check_signup_allowed
    redirect_to root_path, alert: t('user.sign_up_disabled') unless FeatureToggles.allow_user_signup?
  end
end

class User::RegistrationsController < Devise::RegistrationsController
  layout 'sessions', only: %i[new create]

  private

  def sign_up_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end

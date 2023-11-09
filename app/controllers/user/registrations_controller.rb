class User::RegistrationsController < Devise::RegistrationsController
  layout 'sessions', only: %i[new create]

  def create
    super do |user|
      if User.count == 1
        user.admin = true
        user.save
        user.confirm
      end
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end

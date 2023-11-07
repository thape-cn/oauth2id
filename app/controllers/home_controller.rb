class HomeController < ApplicationController
  def index
    @applications = if current_user.present?
      user_allowed_application_ids = current_user.user_allowed_applications.where(enable: true).pluck(:oauth_application_id)
      Doorkeeper::Application.where(id: user_allowed_application_ids)
        .or(Doorkeeper::Application.where(allow_login_by_default: true))
    else
      Doorkeeper::Application.all
    end
  end
end

class HomeController < ApplicationController
  def index
    @applications = if current_user.present?
      current_user.user_allowed_applications.where(enable: true).collect(&:oauth_application)
    else
      Doorkeeper::Application.all
    end
  end
end

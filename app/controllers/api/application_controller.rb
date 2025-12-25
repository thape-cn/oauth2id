# frozen_string_literal: true

module API
  class ApplicationController < ActionController::API
    before_action :authenticate_user!

    def user_info
      u = current_user
      profile = u.profile
      render json: {
        chinese_name: profile&.chinese_name || u.username,
        email: u.email
      }
    end
  end
end

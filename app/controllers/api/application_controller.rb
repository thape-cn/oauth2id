# frozen_string_literal: true

module API
  class ApplicationController < ActionController::API
    before_action :authenticate_user!

    def user_info
      u = current_user
      render json: {
        email: u.email
      }
    end
  end
end

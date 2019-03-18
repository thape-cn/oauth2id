class HomeController < ApplicationController
  def index
    @applications = Doorkeeper::Application.all
  end
end

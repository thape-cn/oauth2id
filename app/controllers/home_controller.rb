class HomeController < ApplicationController
  before_action :doorkeeper_authorize!, only: :me
  before_action -> { doorkeeper_authorize! :public }, only: :profiles

  def index
  end

  def me
    render json: current_resource_owner
  end

  def profiles
    render json: { info: 'more information here' }
  end
end

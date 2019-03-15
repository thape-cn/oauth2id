class DoorkeeperController < ApplicationController
  before_action :doorkeeper_authorize!, only: :me
  before_action -> { doorkeeper_authorize! :public }, only: :profiles
  content_security_policy_report_only only: :options_authorize
  skip_before_action :verify_authenticity_token, only: :options_authorize

  def me
    render json: current_resource_owner
  end

  def profiles
    render json: { info: 'more information here' }
  end

  def options_authorize
    head :no_content
  end

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end

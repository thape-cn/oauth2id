class SystemInfoController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def show
    authorize :SystemInfo

  end
end

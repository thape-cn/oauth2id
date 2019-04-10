class Oauth2ApplicationsController < ApplicationController
  after_action :verify_authorized
  before_action :set_application, only: %i[update]

  def create
    @application = DoorkeeperApplication.new(application_params)
    authorize @application

    if @application.save
      flash[:notice] = I18n.t(:notice, scope: %i[doorkeeper flash applications create])

      respond_to do |format|
        format.html { redirect_to oauth_application_url(@application) }
        format.json { render json: @application }
      end
    else
      respond_to do |format|
        format.html { render 'doorkeeper/applications/new' }
        format.json { render json: { errors: @application.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @application

    if @application.update(application_params)
      flash[:notice] = I18n.t(:notice, scope: %i[doorkeeper flash applications update])

      respond_to do |format|
        format.html { redirect_to oauth_application_url(@application) }
        format.json { render json: @application }
      end
    else
      respond_to do |format|
        format.html { render 'doorkeeper/applications/edit' }
        format.json { render json: { errors: @application.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_application
    @application = DoorkeeperApplication.find(params[:id])
  end

  def application_params
    params.require(:doorkeeper_application)
      .permit(:name, :redirect_uri, :scopes, :confidential, :icon, :div_class, :login_url, :allow_login_by_default)
  end
end

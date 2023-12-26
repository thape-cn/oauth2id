class InstallController < ApplicationController
  before_action :require_no_install, only: [:index, :step1, :step2, :step3]
  layout 'sessions'

  # GET /install
  def index
  end

  # GET /install/step1
  # Check environment
  def step1
    @db_adapter = ActiveRecord::Base.connection.adapter_name.downcase
    @db_name = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: "primary").configuration_hash[:database]
    @master_key_missing = Rails.application.credentials.key.blank?
    @env_valid = !@master_key_missing
  end

  # GET /install/step2
  # Import users data
  def step2
  end

  # GET /install/step3
  # Create admin user
  def step3
    if User.where(admin: true).count > 0
      redirect_to install_step4_path and return
    end
    @new_user = User.new
  end

  # GET /install/step4
  def step4
    @initial_admin_user = User.where(admin: true).first
  end

  # POST /install/step1
  # Just redirect to step2
  def save_step1
    redirect_to install_step2_path
  end

  # POST /install/step2
  # Import users data
  def save_step2
    if params[:button] == "skip"
      redirect_to install_step3_path
    else
      redirect_to install_step2_path, alert: "[Import users] feature is not available in this version" and return
      if params[:file].blank?
        redirect_to install_step2_path, alert: "Please select a file"
      else
        # begin
        #   User.import(params[:file])
        #   redirect_to install_step3_path, notice: "Users imported successfully"
        # rescue => e
        #   redirect_to install_step2_path, alert: e.message
        # end
      end
    end
  end

  # POST /install/step3
  # Create admin user
  def save_step3
    user_params = params.require(:user).permit(:username, :password, :password_confirmation, :email)
    @new_user = User.new(user_params)
    @new_user.admin = true
    @new_user.skip_confirmation!
    if @new_user.save
      redirect_to install_step4_path, notice: "Admin user created successfully"
    else
      render "install/step3"
    end
  end

  private
  def require_no_install
    redirect_to root_path if User.where(admin: true).count > 0
  end
end

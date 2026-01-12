class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile

  def profile
  end

  def update
    case params[:by]
    when 'profile'
      update_profile
    end
  end

  private

  def set_profile
    @profile = current_user.profile || current_user.build_profile
  end

  def profile_params
    params.require(:profile).permit(:title, :gender, :phone, :opencode_api_key)
  end

  def update_profile
    if @profile.update(profile_params)
      redirect_to profile_setting_path, notice: I18n.t('ui.update_success')
    else
      render 'profile'
    end
  end
end

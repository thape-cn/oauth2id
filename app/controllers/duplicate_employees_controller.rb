class DuplicateEmployeesController < ApplicationController
  before_action :authenticate_user!

  def index
    @profiles = policy_scope(Profile)
      .select('chinese_name, clerk_code, COUNT(user_id) account_counts')
      .group(:chinese_name, :clerk_code)
      .having('count(user_id) > 1')
      .where.not(clerk_code: nil)
      .order('account_counts DESC, clerk_code DESC')
  end

  def show
    @clerk_code = params[:id]
    @duplicate_users = User.joins(:profile).where(profile: { clerk_code: @clerk_code })
  end

  def update
  end
end

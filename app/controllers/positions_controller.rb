class PositionsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_policy_scoped

  def index
    authorize Position

    positions = policy_scope(Position)

    respond_to do |format|
      format.html
      format.json { render json: PositionDatatable.new(params, positions: positions, view_context: view_context) }
    end
  end
end

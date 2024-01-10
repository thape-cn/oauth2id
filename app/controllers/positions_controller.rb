class PositionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_position_and_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    authorize Position

    positions = policy_scope(Position)

    respond_to do |format|
      format.html
      format.json { render json: PositionDatatable.new(params, positions: positions, view_context: view_context) }
    end
  end

  def edit
  end

  def update
  end

  private

  def set_position_and_authorized
    @position = Position.find(params[:id])
    authorize @position
  end
end

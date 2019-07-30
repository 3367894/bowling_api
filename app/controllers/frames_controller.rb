class FramesController < ApplicationController
  def create
    creator = FrameCreator.new(frame_params)
    if creator.create
      render json: { frame_id: creator.frame.id }
    else
      render status: 400, json: { errors: creator.errors }
    end
  rescue ActionController::ParameterMissing => e
    render status: 400, json: { errors: [e.message] }
  end

  private

  def permitted_params
    params.require(:frame).permit(:player_id, :points)
  end

  def frame_params
    permitted_params.to_h.symbolize_keys.merge(game_id: params[:game_id])
  end
end

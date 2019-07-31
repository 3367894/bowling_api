class FramesController < ApplicationController
  def create
    creator = FrameCreator.new(frame_creation_params)
    if creator.create
      render json: { frame_id: creator.frame.id }
    else
      render status: 400, json: { errors: creator.errors }
    end
  end

  def update
    updater = FrameUpdater.new(frame_update_params)
    if updater.update
      head :ok
    else
      render status: 400, json: { errors: updater.errors }
    end
  end

  private

  def frame_creation_params
    permitted_params = params.require(:frame).permit(:player_id, :points)
    permitted_params.to_h.symbolize_keys.merge(game_id: params[:game_id])
  end

  def frame_update_params
    permitted_params = params.require(:frame).permit(:points)
    permitted_params.to_h.symbolize_keys.merge(game_id: params[:game_id], frame_id: params[:id])
  end
end

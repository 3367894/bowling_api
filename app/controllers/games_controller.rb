class GamesController < ApplicationController
  def create
    creator = GameCreator.new(permitted_params[:players_list])
    if creator.create
      @game = creator.game
    else
      render status: 400, json: { errors: creator.errors }
    end
  end

  private
  def permitted_params
    params.require(:game).permit(players_list: [])
  end
end

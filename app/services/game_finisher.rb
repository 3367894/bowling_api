class GameFinisher
  def self.check_and_finish(game_id)
    finished = true

    Player.where(game_id: game_id).find_each do |player|
      unless player.frames.where(number: FrameHandler::LAST_FRAME_NUMBER, closed: true).exists?
        finished = false
      end
    end

    if finished
      game = Game.find(game_id)
      game.update(finished_at: Time.now)
    end
  end
end

class FrameHandler
  MAX_POINTS = 10

  attr_reader :frame, :errors

  def initialize(game_id:, points:)
    @errors = []
    @game_id = game_id
    @points = points.to_i
  end

  private

  def check_data
    if game.blank?
      add_error('game_is_not_exists')
      return false
    end

    if game.finished_at.present?
      add_error('game_is_finished')
      return false
    end

    true
  end

  def not_closed_frames_exists?
    Frame.where(game_id: @game_id, closed: false).exists?
  end

  def game
    @game ||= Game.find_by(id: @game_id)
  end

  def add_error(key)
    @errors << I18n.t("frames.errors.#{key}")
  end
end

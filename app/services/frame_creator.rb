class FrameCreator
  STRIKE_POINTS = 10

  attr_reader :frame, :errors

  def initialize(game_id:, player_id:, points:)
    @player_id = player_id
    @points = points
    @game_id = game_id
    @errors = []
  end

  def create
    return false unless check_data

    @frame = Frame.new(
      player_id: @player_id,
      game_id: @game_id,
      first_bowl: @points,
      number: last_number + 1
    )
    if @points == STRIKE_POINTS
      @frame.status = :strike
      @frame.closed = true
    end

    @frame.save
  end

  private

  def check_data
    if game.blank?
      add_error('game_is_not_exists')
      return false
    end

    if player.blank?
      add_error('player_is_not_exists')
      return false
    end

    if game.finished_at.present?
      add_error('game_is_finished')
      return false
    end

    if not_closed_frames_exists?
      add_error('has_not_closed_frame')
      return false
    end

    true
  end

  def last_number
    @number ||= last_players_frame&.number || 0
  end

  def last_players_frame
    @last_players_frame ||= Frame.where(player_id: @player_id).order(:number).last
  end

  def not_closed_frames_exists?
    Frame.where(game_id: @game_id, closed: false).exists?
  end

  def game
    @game ||= Game.find_by(id: @game_id)
  end

  def player
    @player ||= Player.where(game_id: @game_id).find_by(id: @player_id)
  end

  def add_error(key)
    @errors << I18n.t("frames.errors.#{key}")
  end
end

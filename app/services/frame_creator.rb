class FrameCreator < FrameHandler
  def initialize(game_id:, player_id:, points:)
    super(game_id: game_id, points: points)
    @player_id = player_id
  end

  def create
    return false unless check_data

    @frame = Frame.new(
      player_id: @player_id,
      game_id: @game_id,
      first_bowl: @points,
      number: last_number + 1
    )
    if @points == MAX_POINTS
      @frame.status = :strike
      @frame.closed = last_number != LAST_FRAME_NUMBER - 1
    end

    Frame.transaction do
      add_points_to_previous
      @frame.save
    end
  end

  private

  def check_data
    return false unless super

    if player.blank?
      add_error('player_is_not_exists')
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

  def player
    @player ||= Player.where(game_id: @game_id).find_by(id: @player_id)
  end

  def add_points_to_previous
    return if last_players_frame.blank?

    last_players_frame.update(additional: @points) unless last_players_frame.ordinary?

    return if !last_players_frame.strike? || last_players_frame.number == 1

    prev_frame = Frame.where(player_id: @player_id, number: last_players_frame.number - 1).first
    prev_frame.update(additional: @points) if prev_frame.strike?
  end
end

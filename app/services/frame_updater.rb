class FrameUpdater < FrameHandler
  LAST_FRAME_NUMBER = 10

  def initialize(game_id:, frame_id:, points:)
    super(game_id: game_id, points: points)
    @frame_id = frame_id
  end

  def update
    return false unless check_data

    frame.update(attributes)
  end

  private

  def attributes
    attrs = { closed: closed? }
    if third_bowl?
      attrs[:third_bowl] = @points
    else
      attrs[:second_bowl] = @points
      attrs[:status] = :spare if spare?
    end
    attrs
  end

  def closed?
    return true unless last_frame?
    return true if third_bowl?
    return true unless spare?

    false
  end

  def last_frame?
    return @last_frame if defined?(@last_frame)
    @last_frame = frame.number == LAST_FRAME_NUMBER
  end

  def third_bowl?
    return @third_bowl if defined?(@third_bowl)
    return @third_bowl = false if frame.second_bowl.blank?
    return @third_bowl = false if frame.ordinary? && !spare?

    @third_bowl = true
  end

  def spare?
    return @spare if defined?(@spare)
    @spare = !frame.strike? && frame.first_bowl + @points == MAX_POINTS
  end

  def check_data
    return false unless super

    if frame.blank?
      add_error('frame_is_not_exists')
      return false
    end

    if frame.closed?
      add_error('frame_is_closed')
      return false
    end

    return check_sum_of_bowls(frame.first_bowl) unless last_frame?
    return check_sum_of_bowls(frame.first_bowl) unless third_bowl? || frame.strike?
    return check_sum_of_bowls(frame.second_bowl) if frame.strike? && frame.second_bowl < MAX_POINTS

    true
  end

  def frame
    @frame ||= Frame.find_by(id: @frame_id)
  end

  def check_sum_of_bowls(points)
    if points + @points > MAX_POINTS
      add_error('too_much_points')
      return false
    end
    true
  end
end

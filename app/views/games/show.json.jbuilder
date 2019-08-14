json.id @game.id
json.started_at @game.started_at.to_s
json.finished_at @game.finished_at&.to_s

json.players @game.players.sort_by(&:position) do |player|
  json.(player, :name, :id, :total)

  json.frames player.frames.sort_by(&:number) do |frame|
    json.(frame, :id, :number, :first_bowl, :second_bowl, :status, :total)
    json.(frame, :third_bowl) if frame.number == FrameHandler::LAST_FRAME_NUMBER
  end
end

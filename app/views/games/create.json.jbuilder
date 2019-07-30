json.id @game.id
json.players @game.players do |player|
  json.(player, :position, :name)
end

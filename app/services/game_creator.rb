class GameCreator
  attr_reader :game, :errors

  def initialize(player_list)
    @players_list = player_list
    @errors = []
  end

  def create
    return false unless check_players_list

    result = true
    Game.transaction do
      @game = Game.new(started_at: Time.now)
      @players_list.each_with_index do |player_name, index|
        @game.players.build(name: player_name, position: index + 1)
      end
      result = @game.save
      unless result
        @errors += @game.errors.full_messages
      end
    end

    result
  end

  private

  def check_players_list
    if @players_list.empty?
      @errors << I18n.t('game_creator.errors.players_list_is_empty')
      return false
    end

    result = true
    @players_list.each do |player_name|
      if player_name.strip.blank?
        @errors << I18n.t('game_creator.errors.player_name_is_invalid', name: player_name)
        result = false
      end
    end

    result
  end
end

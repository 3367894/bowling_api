require 'rails_helper'

describe GameFinisher do
  describe '.check_and_finish' do
    let(:game) { create(:game) }
    let!(:player_1) { create(:player, game: game, position: 1) }
    let!(:player_2) { create(:player, game: game, position: 2) }

    it 'finishes game is all players are finished' do
      create(:frame, game: game, player: player_1, number: 10, closed: true)
      create(:frame, game: game, player: player_2, number: 10, closed: true)

      GameFinisher.check_and_finish(game.id)
      game.reload
      expect(game.finished_at).not_to be_nil
    end

    it 'not finishes game is one player has not closed last frame' do
      create(:frame, game: game, player: player_1, number: 10, closed: true)
      create(:frame, game: game, player: player_2, number: 10, closed: false)

      GameFinisher.check_and_finish(game.id)
      game.reload
      expect(game.finished_at).to be_nil
    end

    it 'not finishes game is one player has not last frame' do
      create(:frame, game: game, player: player_1, number: 10, closed: true)

      GameFinisher.check_and_finish(game.id)
      game.reload
      expect(game.finished_at).to be_nil
    end
  end
end

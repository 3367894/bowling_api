require 'rails_helper'

describe GamesController do
  render_views

  describe '#create' do
    let(:params) { { game: { players_list: %w(player1 player2 player3) } } }

    it 'has success response' do
      post :create, params: params, format: :json
      expect(response).to be_successful
    end

    it 'creates game' do
      expect {
        post :create, params: params, format: :json
      }.to change { Game.count }.by(1)
    end

    it 'creates players' do
      expect {
        post :create, params: params, format: :json
      }.to change { Player.count }.by(3)
    end

    it 'returns game structure' do
      post :create, params: params, format: :json
      body = JSON.parse(response.body)

      game = Game.last
      expect(body['id']).to eq(game.id)
      expect(body['players'].size).to eq(3)
      3.times do |index|
        player = body['players'][index]
        expect(player['position']).to eq(index + 1)
        expect(player['name']).to eq("player#{index + 1}")
      end
    end

    context 'with errors' do
      it 'returns error about not having game params' do
        post :create, params: {}, format: :json
        expect(response).not_to be_successful
        expect(response.status).to eq(400)

        body = JSON.parse(response.body)
        expect(body['errors']).not_to be_blank
      end

      it 'returns errors from game creation' do
        post :create, params: { game: { players_list: ['   '] } }, format: :json
        expect(response).not_to be_successful
        expect(response.status).to eq(400)

        body = JSON.parse(response.body)
        expect(body['errors']).to(
          eq([I18n.t('game_creator.errors.player_name_is_invalid', name: '   ')])
        )
      end
    end
  end
end

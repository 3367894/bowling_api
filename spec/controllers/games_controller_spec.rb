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

  describe '#show' do
    let(:game) { create(:game, started_at: Time.now) }
    let(:player_1) { create(:player, game: game, name: 'Player1', position: 1) }
    let!(:frame_1_1) do
      create(:frame,
             player: player_1,
             game: game,
             number: 1,
             status: :strike,
             first_bowl: 10,
             additional: 8
      )
    end
    let!(:frame_1_2) do
      create(:frame, player: player_1, game: game, number: 2, status: :ordinary, first_bowl: 8)
    end
    let(:player_2) { create(:player, game: game, name: 'Player1', position: 2) }
    let!(:frame_2_1) do
      create(:frame,
             player: player_2,
             game: game,
             number: 10,
             status: :ordinary,
             first_bowl: 7,
             second_bowl: 3,
             third_bowl: 5
      )
    end

    it 'has success response' do
      get :show, params: { id: game.id }, format: :json
      expect(response).to be_successful
    end

    it 'returns game structure' do
      get :show, params: { id: game.id }, format: :json

      body = JSON.parse(response.body)
      expect(body['started_at']).to eq(game.started_at.to_s)
      expect(body['finished_at']).to be_nil
      expect(body['players'].size).to eq(2)

      player = body['players'].first
      expect(player['name']).to eq(player_1.name)
      expect(player['id']).to eq(player_1.id)
      expect(player['frames'].size).to eq(2)

      frame = player['frames'].first
      expect(frame.keys).to match_array(%w(id number first_bowl second_bowl status total))
      expect(frame['id']).to eq(frame_1_1.id)
      expect(frame['number']).to eq(frame_1_1.number)
      expect(frame['first_bowl']).to eq(frame_1_1.first_bowl)
      expect(frame['second_bowl']).to eq(frame_1_1.second_bowl)
      expect(frame['status']).to eq(frame_1_1.status.to_s)
      expect(frame['total']).to eq(frame_1_1.first_bowl + frame_1_1.additional)
    end

    it 'returns third bowl for tenth frame' do
      get :show, params: { id: game.id }, format: :json

      body = JSON.parse(response.body)
      frame = body['players'].last['frames'].first
      expect(frame.keys).to match_array(%w(id number first_bowl second_bowl third_bowl status total))
    end
  end
end

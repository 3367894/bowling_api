require 'rails_helper'

describe FramesController do
  render_views

  let(:player) { create(:player) }

  describe '#create' do
    let(:params) { { game_id: player.game_id, frame: { player_id: player.id, points: 8 } } }

    it 'has success response' do
      post :create, params: params, format: :json
      expect(response).to be_successful
    end

    it 'creates frame' do
      expect {
        post :create, params: params, format: :json
      }.to change { Frame.count }.by(1)
    end

    it 'returns new frame id' do
      post :create, params: params, format: :json

      frame = Frame.last
      body = JSON.parse(response.body)
      expect(body['frame_id']).to eq(frame.id)
    end

    context 'with errors' do
      it 'returns error about not having player_id params' do
        post :create, params: { game_id: player.game_id }, format: :json
        expect(response).not_to be_successful
        expect(response.status).to eq(400)

        body = JSON.parse(response.body)
        expect(body['errors']).not_to be_blank
      end

      it 'returns errors from frame creation' do
        post :create, format: :json,
             params: { game_id: player.game_id, frame: { player_id: -1, points: 8 } }
        expect(response).not_to be_successful
        expect(response.status).to eq(400)

        body = JSON.parse(response.body)
        expect(body['errors']).to eq([I18n.t('frames.errors.player_is_not_exists')])
      end
    end
  end

  describe '#update' do
    let(:frame) do
      create(:frame, number: 1, player_id: player.id, game_id: player.game_id, first_bowl: 1)
    end
    let(:params) { { game_id: player.game_id, id: frame.id, frame: { points: 8 } } }

    it 'has success response' do
      patch :update, params: params, format: :json
      expect(response).to be_successful
    end

    it 'updates frame' do
      patch :update, params: params, format: :json

      frame.reload
      expect(frame.second_bowl).to eq(8)
      expect(frame.closed).to be_truthy
    end

    context 'with errors' do
      it 'returns errors from frame update' do
        patch :update, format: :json,
              params: { game_id: player.game_id, id: -1, frame: { points: 8 } }
        expect(response).not_to be_successful
        expect(response.status).to eq(400)

        body = JSON.parse(response.body)
        expect(body['errors']).to eq([I18n.t('frames.errors.frame_is_not_exists')])
      end
    end

    context 'finish game' do
      let(:frame) do
        create(:frame,
               number: 10,
               player_id: player.id,
               game_id: player.game_id,
               first_bowl: 1
        )
      end

      it 'finishes game' do
        patch :update, params: params, format: :json

        game = player.game
        game.reload
        expect(game.finished_at).not_to be_nil
      end
    end
  end
end

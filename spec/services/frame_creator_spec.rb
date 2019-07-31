require 'rails_helper'

describe FrameCreator do
  let(:player) { create(:player) }
  let(:options) { { player_id: player.id, points: 8, game_id: player.game_id } }
  subject { described_class.new(options) }

  describe 'create frame' do
    it 'returns status of creation' do
      expect(subject.create).to be_truthy
    end

    it 'creates frame' do
      expect {
        subject.create
      }.to change { Frame.count }.by(1)
    end

    it 'fills frame fields' do
      subject.create

      frame = Frame.last
      expect(frame.game_id).to eq(player.game_id)
      expect(frame.player_id).to eq(player.id)
      expect(frame.status).to eq('ordinary')
      expect(frame.closed).to be_falsey
      expect(frame.number).to eq(1)
      expect(frame.first_bowl).to eq(8)
      expect(frame.second_bowl).to be_nil
      expect(frame.third_bowl).to be_nil
      expect(frame.additional).to eq(0)
    end

    it 'sets next frame if has previous' do
      create(:frame, player: player, number: 5, closed: true, game: player.game)

      expect(subject.create).to be_truthy
      expect(subject.frame.number).to eq(6)
    end

    context 'strike' do
      let(:options) { { player_id: player.id, points: 10, game_id: player.game_id } }

      it 'sets strike and close frame' do
        subject.create

        frame = Frame.last
        expect(frame.status).to eq('strike')
        expect(frame.closed).to be_truthy
      end

      it 'not closes frame on strike if last frame' do
        create(:frame,
               status: :spare,
               player_id: player.id,
               first_bowl: 10,
               number: 9,
               closed: true,
               game_id: player.game_id)
        subject.create

        frame = subject.frame
        expect(frame.number).to eq(10)
        expect(frame.status).to eq('strike')
        expect(frame.closed).to be_falsey
      end
    end

    context 'with errors' do
      it 'returns error if has opened frame' do
        create(:frame, player: player, game: player.game)

        expect(subject.create).to be_falsey
        expect(subject.errors).to eq([I18n.t('frames.errors.has_not_closed_frame')])
      end

      it 'returns error if game is finished' do
        game = player.game
        game.update!(finished_at: Time.now)

        expect(subject.create).to be_falsey
        expect(subject.errors).to eq([I18n.t('frames.errors.game_is_finished')])
      end

      it 'returns error if game is not exists' do
        creator = described_class.new(player_id: player.id, points: 8, game_id: -1)

        expect(creator.create).to be_falsey
        expect(creator.errors).to eq([I18n.t('frames.errors.game_is_not_exists')])
      end

      it 'returns error if player is not exists' do
        creator = described_class.new(player_id: -1, points: 8, game_id: player.game_id)

        expect(creator.create).to be_falsey
        expect(creator.errors).to eq([I18n.t('frames.errors.player_is_not_exists')])
      end
    end
  end

  describe 'additional points' do
    it 'adds points to previous frame if previous has spare' do
      prev_frame = create(:frame,
                          status: :spare,
                          player_id: player.id,
                          first_bowl: 8,
                          second_bowl: 2,
                          additional: 0,
                          number: 1,
                          closed: true,
                          game_id: player.game_id)
      subject.create
      prev_frame.reload
      expect(prev_frame.additional).to eq(8)
    end

    it 'adds points to previous frame is previous has strike' do
      prev_frame = create(:frame,
                          status: :strike,
                          player_id: player.id,
                          first_bowl: 10,
                          additional: 0,
                          number: 1,
                          closed: true,
                          game_id: player.game_id)
      subject.create
      prev_frame.reload
      expect(prev_frame.additional).to eq(8)
    end

    it 'adds points to two previous frames if they have strikes' do
      frame_1 = create(:frame,
                       status: :strike,
                       player_id: player.id,
                       first_bowl: 10,
                       additional: 0,
                       number: 1,
                       closed: true,
                       game_id: player.game_id)
      frame_2 = create(:frame,
                       status: :strike,
                       player_id: player.id,
                       first_bowl: 10,
                       additional: 0,
                       number: 2,
                       closed: true,
                       game_id: player.game_id)

      subject.create
      frame_1.reload
      frame_2.reload
      expect(frame_1.additional).to eq(8)
      expect(frame_2.additional).to eq(8)
    end
  end
end

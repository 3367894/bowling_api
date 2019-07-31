require 'rails_helper'

describe FrameUpdater do
  let(:player) { create(:player) }
  let(:frame) do
    create(:frame, number: 2, player_id: player.id, game_id: player.game_id, first_bowl: 1)
  end
  let(:options) { { frame_id: frame.id, points: 8, game_id: player.game_id } }
  subject { described_class.new(options) }


  describe 'updating frame' do
    it 'returns result of updating' do
      expect(subject.update).to be_truthy
    end

    it 'updates frame' do
      subject.update
      frame.reload

      expect(frame.second_bowl).to eq(8)
      expect(frame.closed).to be_truthy
    end

    context 'spare' do
      let(:options) { { frame_id: frame.id, points: 9, game_id: player.game_id } }

      it 'sets spare is sum of bowls is 10' do
        subject.update
        frame.reload

        expect(frame.status).to eq('spare')
      end
    end

    context 'tenth frame' do
      it 'sets third bowl if first was strike' do
        frame = create(:frame,
                       number: 10,
                       player_id: player.id,
                       game_id: player.game_id,
                       first_bowl: 10,
                       second_bowl: 9,
                       status: :strike
        )
        updater = described_class.new(frame_id: frame.id, points: 1, game_id: player.game_id)
        updater.update

        frame.reload
        expect(frame.third_bowl).to eq(1)
      end

      it 'sets third bowl if second was spare' do
        frame = create(:frame,
                       number: 10,
                       player_id: player.id,
                       game_id: player.game_id,
                       first_bowl: 1,
                       second_bowl: 9,
                       status: :spare
        )
        updater = described_class.new(frame_id: frame.id, points: 1, game_id: player.game_id)
        updater.update

        frame.reload
        expect(frame.third_bowl).to eq(1)
      end
    end

    context 'with errors' do
      it 'returns error if game is finished' do
        game = player.game
        game.update!(finished_at: Time.now)

        expect(subject.update).to be_falsey
        expect(subject.errors).to eq([I18n.t('frames.errors.game_is_finished')])
      end

      it 'returns error if cannot find frame' do
        updater = described_class.new(frame_id: -1, points: 8, game_id: player.game_id)

        expect(updater.update).to be_falsey
        expect(updater.errors).to eq([I18n.t('frames.errors.frame_is_not_exists')])
      end

      it 'returns error if game is not exists' do
        updater = described_class.new(frame_id: frame.id, points: 8, game_id: -1)

        expect(updater.update).to be_falsey
        expect(updater.errors).to eq([I18n.t('frames.errors.game_is_not_exists')])
      end

      it 'returns error if too much points' do
        updater = described_class.new(frame_id: frame.id, points: 10, game_id: player.game_id)

        expect(updater.update).to be_falsey
        expect(updater.errors).to eq([I18n.t('frames.errors.too_much_points')])
      end

      it 'returns error if frame was closed' do
        frame.update(closed: true)
        updater = described_class.new(frame_id: frame.id, points: 10, game_id: player.game_id)

        expect(updater.update).to be_falsey
        expect(updater.errors).to eq([I18n.t('frames.errors.frame_is_closed')])
      end

      context 'tenth frame' do
        it 'returns error if too much points' do
          frame = create(:frame,
                         number: 10,
                         player_id: player.id,
                         game_id: player.game_id,
                         first_bowl: 10,
                         second_bowl: 9
          )
          updater = described_class.new(frame_id: frame.id, points: 2, game_id: player.game_id)

          expect(updater.update).to be_falsey
          expect(updater.errors).to eq([I18n.t('frames.errors.too_much_points')])
        end
      end
    end
  end

  describe 'additional points' do
    it 'adds points to previous frame if previous has strike' do
      prev_frame = create(:frame,
                          status: :strike,
                          player_id: player.id,
                          first_bowl: 10,
                          additional: 0,
                          number: 1,
                          closed: true,
                          game_id: player.game_id)
      subject.update
      prev_frame.reload
      expect(prev_frame.additional).to eq(8)
    end

    it 'not adds points to previous frame if third bowl of tenth frame' do
      prev_frame = create(:frame,
                          status: :strike,
                          player_id: player.id,
                          first_bowl: 10,
                          additional: 0,
                          number: 9,
                          closed: true,
                          game_id: player.game_id)
      frame = create(:frame,
                     number: 10,
                     status: :spare,
                     player_id: player.id,
                     game_id: player.game_id,
                     first_bowl: 1,
                     second_bowl: 9)

      options = { frame_id: frame.id, points: 8, game_id: player.game_id }
      updater = described_class.new(options)
      updater.update

      prev_frame.reload
      expect(prev_frame.additional).to eq(0)
    end
  end
end

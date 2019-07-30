require 'rails_helper'

describe FrameCreator do
  let(:player) { create(:player) }
  let(:options) { { player_id: player.id, points: 8, game_id: player.game_id } }
  subject { described_class.new(options) }

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
    expect(frame.additional).to be_nil
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

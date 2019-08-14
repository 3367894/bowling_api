require 'rails_helper'

describe GameCreator do
  let(:players_list) { %w(Player1 Player2 Player3) }
  subject { described_class.new(players_list) }

  it 'creates game' do
    expect {
      subject.create
    }.to change { Game.count }.by(1)
  end

  it 'returns result of creating' do
    res = subject.create
    expect(res).to be_truthy
  end

  it 'creates players for game' do
    expect {
      subject.create
    }.to change { Player.count }.by(3)

    game = subject.game
    expect(game.players.pluck(:name)).to match(%w(Player1 Player2 Player3))
  end

  it 'creates players with position' do
    subject.create
    game = subject.game

    game.players.order(:position).each_with_index do |player, index|
      expect(player.position).to eq(index + 1)
      expect(player.name).to eq("Player#{index + 1}")
    end
  end

  context 'with errors' do
    it 'add errors about player names' do
      creator = described_class.new(['Player1', '   '])
      expect(creator.create).to be_falsey
      expect(creator.errors).to(
        eq([I18n.t('game_creator.errors.player_name_is_invalid', name: '   ')])
      )
    end

    it 'adds errors about empty player list' do
      creator = described_class.new([])
      expect(creator.create).to be_falsey
      expect(creator.errors).to eq([I18n.t('game_creator.errors.players_list_is_empty')])
    end
  end
end

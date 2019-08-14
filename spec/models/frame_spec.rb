require 'rails_helper'

describe Frame do
  describe '#total' do
    it 'returns simple sum of points' do
      frame = build(:frame, first_bowl: 9, second_bowl: 1, additional: 3, number: 1)
      expect(frame.total).to eq(13)
    end

    it 'returns sum of points if has only first bowl' do
      frame = build(:frame, first_bowl: 10, number: 1)
      expect(frame.total).to eq(10)
    end

    it 'returns sum of points with third_bowl if tenth frame' do
      frame = build(:frame, first_bowl: 9, second_bowl: 1, additional: 3, third_bowl: 4, number: 10)
      expect(frame.total).to eq(17)
    end
  end
end

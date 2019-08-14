class Frame < ApplicationRecord
  belongs_to :player
  belongs_to :game

  enum status: [:ordinary, :strike, :spare]

  validates :number, presence: true,
            numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }

  validates :first_bowl, presence: true,
            numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :second_bowl, allow_nil: true,
            numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :third_bowl, allow_nil: true,
            numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }

  def total
    total = first_bowl.to_i + second_bowl.to_i + additional
    total += third_bowl.to_i if number == FrameHandler::LAST_FRAME_NUMBER
    total
  end
end

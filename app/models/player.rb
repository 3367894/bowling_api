class Player < ApplicationRecord
  belongs_to :game
  has_many :frames, dependent: :destroy

  validates :name, presence: true, length: { minimum: 1 }
  validates :position, presence: true, numericality: { greater_than: 0 },
            uniqueness: { scope: :game_id }

  def total
    frames.sum(&:total)
  end
end

class Game < ApplicationRecord
  has_many :players

  validates :started_at, presence: true
end

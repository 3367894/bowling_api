class Game < ApplicationRecord
  has_many :players, dependent: :destroy

  validates :started_at, presence: true
end

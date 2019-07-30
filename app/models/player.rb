class Player < ApplicationRecord
  belongs_to :game

  validates :name, presence: true, length: { minimum: 1 }
  validates :position, presence: true, numericality: { greater_than: 0 }
end

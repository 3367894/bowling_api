class CreateFrames < ActiveRecord::Migration[5.2]
  def change
    create_table :frames do |t|
      t.integer :status, default: 0
      t.boolean :closed, default: false
      t.integer :number
      t.integer :first_bowl
      t.integer :second_bowl
      t.integer :third_bowl
      t.integer :additional, default: 0
      t.references :player, foreign_key: true
      t.references :game, foreign_key: true

      t.timestamps
    end
  end
end

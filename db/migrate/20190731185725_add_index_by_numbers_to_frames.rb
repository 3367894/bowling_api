class AddIndexByNumbersToFrames < ActiveRecord::Migration[5.2]
  def change
    add_index :frames, :number
  end
end

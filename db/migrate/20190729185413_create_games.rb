class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.timestamp :started_at
      t.timestamp :finished_at

      t.timestamps
    end
  end
end

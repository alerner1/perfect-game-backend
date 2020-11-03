class CreateGameGameModes < ActiveRecord::Migration[6.0]
  def change
    create_table :game_game_modes do |t|
      t.belongs_to :game, null: false, foreign_key: true
      t.belongs_to :game_mode, null: false, foreign_key: true

      t.timestamps
    end
  end
end

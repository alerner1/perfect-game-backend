class CreateGameMultiplayerModes < ActiveRecord::Migration[6.0]
  def change
    create_table :game_multiplayer_modes do |t|
      t.belongs_to :game, null: false, foreign_key: true
      t.belongs_to :multiplayer_mode, null: false, foreign_key: true

      t.timestamps
    end
  end
end

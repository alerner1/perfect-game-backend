class AddColumnsToGameMultiplayerMode < ActiveRecord::Migration[6.0]
  def change
    add_column :game_multiplayer_modes, :min, :integer
    add_column :game_multiplayer_modes, :max, :integer
  end
end

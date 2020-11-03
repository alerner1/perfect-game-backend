class AddColumnsToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :storyline, :string
    add_column :games, :summary, :string
    add_column :games, :total_rating, :float
    add_column :games, :involved_companies, :string
    add_column :games, :game_profile, :string
  end
end

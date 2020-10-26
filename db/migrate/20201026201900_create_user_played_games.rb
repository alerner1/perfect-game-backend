class CreateUserPlayedGames < ActiveRecord::Migration[6.0]
  def change
    create_table :user_played_games do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :game, null: false, foreign_key: true
      t.integer :liked
    end
  end
end

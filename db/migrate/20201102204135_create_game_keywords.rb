class CreateGameKeywords < ActiveRecord::Migration[6.0]
  def change
    create_table :game_keywords do |t|
      t.belongs_to :game, null: false, foreign_key: true
      t.belongs_to :keyword, null: false, foreign_key: true

      t.timestamps
    end
  end
end

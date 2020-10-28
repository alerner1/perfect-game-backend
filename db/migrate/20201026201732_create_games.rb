class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.integer :igdb_id
      t.string :name
      t.string :cover_url
      t.string :release_date
      t.string :platforms
    end
  end
end

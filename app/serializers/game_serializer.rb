class GameSerializer < ActiveModel::Serializer
  attributes :id, :igdb_id, :name, :cover_url, :release_date, :platforms, :storyline, :summary, :total_rating, :involved_companies
  has_many :genres
  has_many :game_modes
  has_many :multiplayer_modes
end
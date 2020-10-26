class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :steam_name, :steam_id, :owned_games, :recced_games, :wishlist_games
  has_many :played_games

end
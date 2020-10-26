class User < ApplicationRecord
  has_secure_password
  has_many :user_games
  has_many :games, through: :user_games
  has_many :user_played_games
  has_many :played_games, through: :user_played_games, :source => :game

  def owned_games
    games_by_list("owned")
  end

  def wishlist_games
    games_by_list("wish")
  end

  def recced_games
    games_by_list("rec")
  end

  # def played_games
  #   games_by_list("played")
  # end

  private

  def games_by_list(list)
    games.where(user_games: { list: list })
  end
end

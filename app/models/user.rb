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

  def build_profile_vector
    # simplified version where we only consider likes:
    # need to go through all the games they liked (user_played_games where liked == 1)
    # get the genres for those games
    # add 1 to appropriate part of array/vector for each of those genres
    # divide entire array/vector by total number of liked games
    # and that's the user profile

    # strat: for each game, build its vector, then add them together, then divide by total num of games via vector.map{ |e| e.to_f / total}
    
    user_profile = Vector.zero(23) 
    
    counter = 0
    
    self.user_played_games.each do |user_played_game|
      # change num in parens to match total elements of desired vector
      if user_played_game.liked == 1
        game = user_played_game.game
        
        game_profile = game.build_vector

        user_profile = user_profile + game_profile

        counter += 1
      end

    end
    
    user_profile.map do |e| 
      e.to_f / counter
    end
    # it works!!!
    
    # later, add if/else statements for when liked is 0 or -1
    # for 0, add to the total number of games but don't add anything to vector
    # for -1, subtract from appropriate part of array/vector
  end

  def quick_recommendations
    # just one recommendation for now
    # build user vector
    user_profile = self.build_profile_vector
    # similarity = 0
    # best_game = nil
    best_games = []

    Game.all.each do |game|
      next if game.genres.length == 0

      game_profile = game.build_vector
      
      new_similarity = Game.cosine_similarity(user_profile, game_profile)

      next if new_similarity == 0.0

      best_games.push({game: game, similarity: new_similarity})
      # next if new_similarity < similarity

      # similarity = new_similarity
      # best_game = game
      
      break if best_games.length > 1000
    end
    byebug
    # for each game, build game vector
    # calculate similarity
    # if similarity is greater than previous greatest similarity, keep that game
  end

  private

  def games_by_list(list)
    games.where(user_games: { list: list })
  end
end

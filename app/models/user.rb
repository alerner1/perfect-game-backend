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
    
    # change to 45 + 75 after building all new game vectors
    user_profile = Vector.zero(45 + 75) 
    
    counter = 0
    
    self.user_played_games.each do |user_played_game|
      # change num in parens to match total elements of desired vector
      if user_played_game.liked == 1
        game = user_played_game.game
        
        game_profile = game.game_profile

        user_profile = user_profile + game_profile

        counter += 1
      elsif user_played_game.liked == 0
        counter += 1
      elsif user_played_game.liked == -1
        game = user_played_game.game

        game_profile = game.game_profile

        user_profile = user_profile - game_profile

        counter += 1
      end

    end
    
    user_profile.map do |e| 
      e.to_f / counter unless counter == 0
    end
    # it works!!!
    
    # later, add if/else statements for when liked is 0 or -1
    # for 0, add to the total number of games but don't add anything to vector
    # for -1, subtract from appropriate part of array/vector
  end

  def quick_recommendations
    user_profile = self.build_profile_vector
    best_games = []

    Game.all.each do |game|
      
      # don't even bother if it's > 15 years old, has total rating < 70 (or doesn't have a total rating at all), or its game profile is a zero vector and therefore meaningless
      next if game.release_date.to_i < 2005
      next if game.total_rating == nil || game.total_rating < 70
      next if game.game_profile.zero?

      similarity = Game.cosine_similarity(user_profile, game.game_profile)

      # don't even bother adding/checking if there's no similarity at all
      next if similarity == 0.0

      if best_games.length >= 100
        least_similar = best_games.min_by do |e|
          e[:similarity]
        end
      
        if similarity > least_similar[:similarity]
          next if self.played_games.any? do |played_game|
            played_game.igdb_id == game.igdb_id
          end

          next if self.recced_games.any? do |recced_game|
            recced_game.igdb_id == game.igdb_id
          end

          game_index = best_games.index(least_similar)
          best_games[game_index] = {game: game, similarity: similarity}
        end
      else # if it's shorter than 100
        next if self.played_games.any? do |played_game|
          played_game.igdb_id == game.igdb_id
        end

        next if self.recced_games.any? do |recced_game|
          recced_game.igdb_id == game.igdb_id
        end

        best_games.push({game: game, similarity: similarity})
      end
    end

    sorted = best_games.sort_by do |game|
      game[:similarity]
    end.reverse

    only_games = sorted.map do |game|
      game[:game]
    end
  end

  def advanced_recommendations(parameters)

    user_profile = self.build_profile_vector
    best_games = []
    sql_query = Game.where({release_date: parameters[:releaseDate][0].. parameters[:releaseDate][1]}).joins(:genres, :game_modes, :multiplayer_modes).where(:game_modes => {name: parameters[:gameModes]}, :genres => {name: parameters[:genres]})

    # two versions here -- if they did specify multiplayer mode and if they didn't

    if !parameters[:multiplayerModes].empty?
      sql_query = Game.where({release_date: (parameters[:releaseDate][0] - 1) .. parameters[:releaseDate][1]}).joins(:genres, :game_modes, :multiplayer_modes).where(:game_modes => {name: parameters[:gameModes]}, :genres => {name: parameters[:genres]}, :multiplayer_modes => {name: parameters[:multiplayerModes]})
    end

    sql_query.each do |game|
      next if game.total_rating == nil || game.total_rating < 70
      next if game.game_profile.zero?

      # platforms are serialized and therefore a bit more complicated so we do them separately here instead of in sql above
      next if game.platforms.empty?

      platform_abbrevs = game.platforms.map do |platform|
        platform["abbreviation"]
      end

      next if (platform_abbrevs & parameters[:platforms]).empty?

      similarity = Game.cosine_similarity(user_profile, game.game_profile)

      # don't even bother adding/checking if there's no similarity at all
      next if similarity == 0.0

      if best_games.length >= 100
        least_similar = best_games.min_by do |e|
          e[:similarity]
        end
      
        if similarity > least_similar[:similarity]
          next if self.played_games.any? do |played_game|
            played_game.igdb_id == game.igdb_id
          end

          next if self.recced_games.any? do |recced_game|
            recced_game.igdb_id == game.igdb_id
          end
          
          game_index = best_games.index(least_similar)
          best_games[game_index] = {game: game, similarity: similarity}
        end
      else # if it's shorter than 100
        next if self.played_games.any? do |played_game|
          played_game.igdb_id == game.igdb_id
        end

        next if self.recced_games.any? do |recced_game|
          recced_game.igdb_id == game.igdb_id
        end

        best_games.push({game: game, similarity: similarity})
      end
    end

    sorted = best_games.sort_by do |game|
      game[:similarity]
    end.reverse

    only_games = sorted.map do |game|
      game[:game]
    end
  end

  private

  def games_by_list(list)
    games.where(user_games: { list: list })
  end
end

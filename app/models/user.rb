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
      elsif user_played_game.liked == -1
        game = user_played_game.game

        game_profile = game.game_profile

        user_profile = user_profile - game_profile
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
          game_index = best_games.index(least_similar)
          best_games[game_index] = {game: game, similarity: similarity}
        end
      else # if it's shorter than 100
        best_games.push({game: game, similarity: similarity})
      end

      # :06 skipping games with no total rating or total rating < 70
      # :17 skipping games older than 05
      # :44 without skipping oldest games
      # took 3:45 ish with checking for genres and themes length
      # break if best_games.length > 1000
    end

    sorted = best_games.sort_by do |game|
      game[:similarity]
    end.reverse

    only_games = sorted.map do |game|
      game[:game]
    end
  end

  def test_recs
    results = Game.includes(:genres)
    filtered = results.filter do |result|
      result.genres.map do |r|
        r.name
      end.include?('Strategy')
    end
    byebug
  end

  def advanced_recommendations(parameters)
    user_profile = self.build_profile_vector
    best_games = []

    Game.includes(:genres, :game_modes, :multiplayer_modes).each do |game|
      
      next if game.release_date.to_i < parameters[:releaseDate][0].to_i || game.release_date.to_i > parameters[:releaseDate][1].to_i
      next if game.total_rating == nil || game.total_rating < 70
      next if game.game_profile.zero?
      next if game.genres.empty? || game.platforms.empty? || game.game_modes.empty?

      genre_names = game.genres.map do |genre|
        genre.name
      end

      next if (genre_names & parameters[:genres]).empty?

      game_mode_names = game.game_modes.map do |game_mode|
        game_mode.name
      end

      next if (game_mode_names & parameters[:gameModes]).empty?

      # if they've specified multiplayer modes
      if !parameters[:multiplayerModes].empty?
        next if game.multiplayer_modes.empty?
        multiplayer_mode_names = game.multiplayer_modes.map do |multiplayer_mode|
          multiplayer_mode.name
        end

        next if (multiplayer_mode_names & parameters[:multiplayerModes]).empty?
      end

      similarity = Game.cosine_similarity(user_profile, game.game_profile)

      # don't even bother adding/checking if there's no similarity at all
      next if similarity == 0.0

      if best_games.length >= 100
        least_similar = best_games.min_by do |e|
          e[:similarity]
        end
      
        if similarity > least_similar[:similarity]
          game_index = best_games.index(least_similar)
          best_games[game_index] = {game: game, similarity: similarity}
        end
      else # if it's shorter than 100
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

  def advanced_recommendations_old(parameters)
    user_profile = self.build_profile_vector
    best_games = []
    

    filtered_games = Game.includes(:genres).filter do |game|
      flag = true

      if game.game_profile.zero?
        flag = false
      end

      if flag == true && game.platforms
        platform_names = game.platforms.map do |platform|
            platform["abbreviation"]
        end
        if (platform_names & parameters[:platforms]).empty?
          flag = false
        end
      else # no platforms
        flag = false
      end

      if flag == true && !(game.release_date && game.release_date.to_i > parameters[:releaseDate][0] && game.release_date.to_i < parameters[:releaseDate][1])
        flag = false
      end

      if flag == true && game.genres # only bother with this if flag is still true
        genre_names = game.genres.map do |genre|
          genre.name
        end
        if (genre_names & parameters[:genres]).empty?
          flag = false
        end
      else
        flag = false
      end

      flag
    end

    filtered_games.each do |game|
      # don't even bother if it's > 15 years old, has total rating < 70 (or doesn't have a total rating at all), or its game profile is a zero vector and therefore meaningless
      next if game.total_rating == nil || game.total_rating < 70
      next if game.game_profile.zero?
      # next if (game.platforms && (game.platforms & parameters[:platforms]).empty?)

      # next if game.release_date.to_i < parameters.releaseDate[0]
      # next if game.release_date.to_i > parameters.releaseDate[1]

      # next if (game.genres & parameters.genres).empty?

      # next if (game.game_modes & parameters.gameModes).empty?

      # next if !parameters.multiplayerModes.empty? && (game.multiplayer_modes & parameters.multiplayerModes).empty?

      # next if parameters.onlyOwned && !self.owned_games.find(game)

      similarity = Game.cosine_similarity(user_profile, game.game_profile)

      # don't even bother adding/checking if there's no similarity at all
      next if similarity == 0.0

      # if best_games.length >= 100
      #   least_similar = best_games.min_by do |e|
      #     e[:similarity]
      #   end
      
      #   if similarity > least_similar[:similarity]
      #     game_index = best_games.index(least_similar)
      #     best_games[game_index] = {game: game, similarity: similarity}
      #   end
      # else # if it's shorter than 100
        best_games.push({game: game, similarity: similarity})
      # end
      # best_games.filter! do |best_game|
      #   if best_game[:game].platforms
      #     platform_names = best_game[:game].platforms.map do |platform|
      #         platform["abbreviation"]
      #     end
      #     !(platform_names & parameters[:platforms]).empty?
      #   end
      # end
      # :06 skipping games with no total rating or total rating < 70
      # :17 skipping games older than 05
      # :44 without skipping oldest games
      # took 3:45 ish with checking for genres and themes length
      # break if best_games.length > 1000
    end

    recs = best_games.sort_by do |game|
      game[:similarity]
    end.reverse

    formatted = recs.map do |game|
      game[:game]
    end

    byebug

  end

  private

  def games_by_list(list)
    games.where(user_games: { list: list })
  end
end

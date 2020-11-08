class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :user_played_games
  has_many :played_users, through: :user_played_games, :source => :user
  has_many :game_genres
  has_many :genres, through: :game_genres
  has_many :game_game_modes
  has_many :game_modes, through: :game_game_modes
  has_many :game_keywords
  has_many :keywords, through: :game_keywords
  has_many :game_multiplayer_modes
  has_many :multiplayer_modes, through: :game_multiplayer_modes
  has_many :game_themes
  has_many :themes, through: :game_themes
  serialize :platforms
  serialize :involved_companies
  serialize :game_profile

  IGDB_ID = Rails.application.credentials.igdb[:igdb_id]
  IGDB_ACCESS_TOKEN = Rails.application.credentials.igdb[:igdb_access_token]
  BASE_URL = "https://api.igdb.com/v4"
  HEADERS = {
    "Client-ID": IGDB_ID,
    Authorization: "Bearer #{IGDB_ACCESS_TOKEN}",
  }

  def self.reformat_results(games_array)
    games_array.each do |game|
      game["igdb_id"] = game["id"]
      game.delete("id")


      # TODO: fix first release date and liked values -- first release date should just be release date and liked value may be unnecessary.
      game["first_release_date"] = Time.at(game["first_release_date"]).to_datetime.strftime("%Y") unless game["first_release_date"] == nil
      game["release_date"] = game["first_release_date"] unless game["first_release_date"] == nil

      game["liked"] = false

      if game["cover"] != nil
        split_img_url = game["cover"]["url"].split("t_thumb")
        game["cover"]["url"] = split_img_url.join("t_1080p")
        game["cover_url"] = game["cover"]["url"]
        game.delete("cover")
      end
    end
  end

  def self.get_popular_games
    body = '
            fields id, name, cover.url, first_release_date, platforms.abbreviation;
            sort total_rating desc;
            where total_rating != null & total_rating_count > 300 & parent_game = null & name != "The Last of Us Remastered";
            limit 25;
          '

    games_info = HTTParty.post(
      "#{BASE_URL}/games",
      :headers => HEADERS,
      :body => body
    ).parsed_response

    Game.reformat_results(games_info)
  end

  def self.search(query)
    body = "
            search \"#{query.to_s}\";
            where parent_game = null;
            fields id, name, cover.url, first_release_date, storyline, summary, total_rating, multiplayer_modes.*, game_modes.name, platforms.abbreviation, genres.name, themes.name;
            limit 100;
          "

    search_results = HTTParty.post(
      "#{BASE_URL}/games",
      :headers => HEADERS,
      :body => body,
    ).parsed_response

    Game.reformat_results(search_results)
  end

  def self.get_quick_recs(current_user)
    current_user.quick_recommendations
  end

  def self.get_all_games
    offset = 0

    while offset < 135000 do
      body = "
              fields id, name, cover.url, first_release_date, storyline, summary, total_rating, multiplayer_modes.*, game_modes.name, involved_companies.*, keywords.name, platforms.abbreviation, genres.name, themes.name; 
              limit 500;
              offset #{offset};
            "

      games_info = HTTParty.post(
        "#{BASE_URL}/games",
        :headers => HEADERS,
        :body => body
      ).parsed_response

      reformatted_games_info = Game.reformat_results(games_info)
      
      reformatted_games_info.each do |game|
        game.delete('first_release_date')
        game.delete('liked')

        # still need to store: storyline, summary, total_rating, multiplayer_modes, game_modes, involved_companies, keywords.name, themes.name
        # plain attributes: storyline, summary, total_rating
        # serialize: involved_companies (maybe?)
        # new models: multiplayer_modes, game_modes, keywords, themes

        genres = game['genres']
        game.delete('genres')

        multiplayer_modes = game['multiplayer_modes']
        game.delete('multiplayer_modes')

        game_modes = game['game_modes']
        game.delete('game_modes')

        keywords = game['keywords']
        game.delete('keywords')

        themes = game['themes']
        game.delete('themes')
        
        # if multiplayer_modes
        #   byebug
        # end

        stored_game = Game.find_or_create_by(igdb_id: game["igdb_id"])
        stored_game.update(game)

        genres.each do |genre|
          stored_genre = Genre.find_by(name: genre['name'])
          GameGenre.find_or_create_by(game: stored_game, genre: stored_genre)
        end unless !genres

        themes.each do |theme|
          stored_theme = Theme.find_by(name: theme['name'])
          GameTheme.find_or_create_by(game: stored_game, theme: stored_theme)
        end unless !themes

        keywords.each do |keyword|
          stored_keyword = Keyword.find_by(name: keyword['name'])
          GameKeyword.find_or_create_by(game: stored_game, keyword: stored_keyword)
        end unless !keywords

        game_modes.each do |game_mode|
          stored_game_mode = GameMode.find_by(name: game_mode['name'])
          GameGameMode.find_or_create_by(game: stored_game, game_mode: stored_game_mode)
        end unless !game_modes

        # doesn't store max num of players, will figure that out later 
        # if necessary/desired
        multiplayer_modes.each do |mm_obj|
          mm_obj.each do |key, value|
            if value == true
              multiplayer_mode = MultiplayerMode.find_by(name: key)
              GameMultiplayerMode.find_or_create_by(game: stored_game, multiplayer_mode: multiplayer_mode)
            end
          end
        end unless !multiplayer_modes

        # game_profile = stored_game.build_vector
        # stored_game.update(game_profile: game_profile)
      end

      offset += 500
    end
    
    Game.refresh_game_profiles
  end

  def self.get_companies
    body = "
            fields name; 
            limit 500; 
            offset 28000;
          "

    companies_info = HTTParty.post(
      "#{BASE_URL}/companies",
      :headers => HEADERS,
      :body => body
    ).parsed_response

    # total 28384
    byebug
  end

  def self.refresh_game_profiles
    most_common_keywords = Keyword.most_common

    Game.all.each do |game|
      new_profile = game.build_vector(most_common_keywords)
      game.update(game_profile: new_profile)
    end
  end

  def build_vector(most_common_keywords)
    # the good news is that we can always create a method to assign all new game profiles (and just game profiles) when we inevitably expand this vector
    
    # there are 75 keywords in the Keyword.most_common vector
    
    game_profile = Vector.zero(Genre.all.length + Theme.all.length + 75)
    sorted_categories = Genre.sorted_by_name + Theme.sorted_by_name + most_common_keywords

    self.genres.each do |genre|
      genre_index = sorted_categories.index(genre)
      game_profile[genre_index] = 1
    end unless self.genres.length == 0

    self.themes.each do |theme|
      theme_index = sorted_categories.index(theme)
      game_profile[theme_index] = 1
    end unless self.themes.length == 0

    self.keywords.each do |keyword|
      keyword_index = sorted_categories.index(keyword)
      game_profile[keyword_index] = 1 unless keyword_index == nil
    end unless self.keywords.length == 0

    game_profile
    
  end

  def self.cosine_similarity(vector1, vector2)
    dot_product = vector1.inner_product vector2
    magnitude_product = vector1.r * vector2.r

    dot_product / magnitude_product

    # i think i did it?????
  end
end

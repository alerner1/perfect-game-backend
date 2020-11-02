class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :user_played_games
  has_many :played_users, through: :user_played_games, :source => :user
  serialize :platforms

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
            fields id, name, cover.url, first_release_date, platforms.abbreviation;
            limit 100;
          "

    search_results = HTTParty.post(
      "#{BASE_URL}/games",
      :headers => HEADERS,
      :body => body,
    ).parsed_response

    Game.reformat_results(search_results)
  end

  def self.get_quick_recs
    body = "
            fields id, name, cover.url, first_release_date, platforms.abbreviation;
            sort total_rating desc;
            limit 10;
          "

    games_info = HTTParty.post(
      "#{BASE_URL}/games",
      :headers => HEADERS,
      :body => body
    ).parsed_response

    Game.reformat_results(games_info)
  end

  def self.get_all_games
    body = "
            fields id, name, cover.url, first_release_date, platforms.abbreviation; 
            limit 500;
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
      stored_game = Game.find_or_create_by(igdb_id: game["igdb_id"])
      stored_game.update(game)
    end
  end

  def self.get_num_of_games
    body = "
            fields id, name, cover.url, first_release_date, platforms.abbreviation; 
            limit 500; 
            offset 134500;
          "

    games_info = HTTParty.post(
      "#{BASE_URL}/games",
      :headers => HEADERS,
      :body => body
    ).parsed_response

    # length right now: 134695
    byebug
    # so basically check if array is empty, if so stop if not continue
  end

  def self.get_genres
    body = "
            fields name; 
            limit 500;
          "

    genres_info = HTTParty.post(
      "#{BASE_URL}/genres",
      :headers => HEADERS,
      :body => body
    ).parsed_response
    
    # length: 23
    byebug
  end

  def self.get_keywords
    body = "
            fields name; 
            limit 500; 
            offset 25500;
          "

    keywords_info = HTTParty.post(
      "#{BASE_URL}/keywords",
      :headers => HEADERS,
      :body => body
    ).parsed_response

    # length: 25821
    byebug
  end
end

class Genre < ApplicationRecord
  has_many :game_genres
  has_many :games, through: :game_genres

  IGDB_ID = Rails.application.credentials.igdb[:igdb_id]
  IGDB_ACCESS_TOKEN = Rails.application.credentials.igdb[:igdb_access_token]
  BASE_URL = "https://api.igdb.com/v4"
  HEADERS = {
    "Client-ID": IGDB_ID,
    Authorization: "Bearer #{IGDB_ACCESS_TOKEN}",
  }

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
    
    genres_info.each do |genre|
      Genre.find_or_create_by(name: genre['name'])
    end

    # length: 23
  end

  def self.sorted_by_name
    self.all.sort_by do |genre|
      genre.name
    end
  end
end
class GameMode < ApplicationRecord
  has_many :game_game_modes
  has_many :games, through: :game_game_modes

  IGDB_ID = Rails.application.credentials.igdb[:igdb_id]
  IGDB_ACCESS_TOKEN = Rails.application.credentials.igdb[:igdb_access_token]
  BASE_URL = "https://api.igdb.com/v4"
  HEADERS = {
    "Client-ID": IGDB_ID,
    Authorization: "Bearer #{IGDB_ACCESS_TOKEN}",
  }

  def self.get_game_modes
    offset = 0

    while offset < 500 do 
      body = "
              fields name; 
              limit 500; 
              offset #{offset};
            "
  
      game_modes_info = HTTParty.post(
        "#{BASE_URL}/game_modes",
        :headers => HEADERS,
        :body => body
      ).parsed_response
  
      game_modes_info.each do |game_mode|
        GameMode.find_or_create_by(name: game_mode['name'])
      end
      
      offset += 500
      # length: 25821
    end

  end

  def self.sorted_by_name
    self.all.sort_by do |game_mode|
      game_mode.name
    end
  end
end

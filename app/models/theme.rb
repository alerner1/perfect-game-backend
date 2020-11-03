class Theme < ApplicationRecord
  has_many :game_themes
  has_many :games, through: :game_themes

  IGDB_ID = Rails.application.credentials.igdb[:igdb_id]
  IGDB_ACCESS_TOKEN = Rails.application.credentials.igdb[:igdb_access_token]
  BASE_URL = "https://api.igdb.com/v4"
  HEADERS = {
    "Client-ID": IGDB_ID,
    Authorization: "Bearer #{IGDB_ACCESS_TOKEN}",
  }


  def self.get_themes
    offset = 0

    while offset < 500 do 
      body = "
              fields name; 
              limit 500; 
              offset #{offset};
            "
  
      themes_info = HTTParty.post(
        "#{BASE_URL}/themes",
        :headers => HEADERS,
        :body => body
      ).parsed_response
  
      themes_info.each do |theme|
        Theme.find_or_create_by(name: theme['name'])
      end
      
      offset += 500
      # length: 22
    end

  end

  def self.sorted_by_name
    self.all.sort_by do |theme|
      theme.name
    end
  end
end

class Keyword < ApplicationRecord
  has_many :game_keywords
  has_many :games, through: :game_keywords

  IGDB_ID = Rails.application.credentials.igdb[:igdb_id]
  IGDB_ACCESS_TOKEN = Rails.application.credentials.igdb[:igdb_access_token]
  BASE_URL = "https://api.igdb.com/v4"
  HEADERS = {
    "Client-ID": IGDB_ID,
    Authorization: "Bearer #{IGDB_ACCESS_TOKEN}",
  }

  def self.get_keywords
    offset = 0

    while offset < 26000 do 
      body = "
              fields name; 
              limit 500; 
              offset #{offset};
            "
  
      keywords_info = HTTParty.post(
        "#{BASE_URL}/keywords",
        :headers => HEADERS,
        :body => body
      ).parsed_response
  
      keywords_info.each do |keyword|
        Keyword.find_or_create_by(name: keyword['name'])
      end
      
      offset += 500
      # length: 25821
    end

  end

  def self.sorted_by_name
    self.all.sort_by do |keyword|
      keyword.name
    end
  end
end

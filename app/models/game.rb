class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :user_played_games
  has_many :played_users, through: :user_played_games, :source => :user

  def self.get_popular_games
    igdb_id = Rails.application.credentials.igdb[:igdb_id]
    igdb_access_token = Rails.application.credentials.igdb[:igdb_access_token]

    HTTParty.post(
      'https://api.igdb.com/v4/games/', 
      :body => 'fields name,rating,rating_count;
               sort rating desc;
               where rating != null & total_rating_count > 300;
               limit 25;',
      :headers => {
        "Client-ID": igdb_id,
        Authorization: "Bearer #{igdb_access_token}"
      },
    ).parsed_response
  end
end
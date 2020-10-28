class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :user_played_games
  has_many :played_users, through: :user_played_games, :source => :user

  

  def self.get_popular_games
    igdb_id = Rails.application.credentials.igdb[:igdb_id]
    igdb_access_token = Rails.application.credentials.igdb[:igdb_access_token]

    games_info = HTTParty.post(
      'https://api.igdb.com/v4/games/', 
      :body => 'fields id, name,cover.url,first_release_date;
               sort rating desc;
               where rating != null & total_rating_count > 300 & parent_game = null & name != "The Last of Us Remastered";
               limit 25;',
      :headers => {
        "Client-ID": igdb_id,
        Authorization: "Bearer #{igdb_access_token}"
      },
    ).parsed_response

    games_info.each do |game|
      game['first_release_date'] = Time.at(game['first_release_date']).to_datetime.strftime('%Y')
      split_img_url = game['cover']['url'].split('t_thumb')
      game['cover']['url'] = split_img_url.join('t_1080p')
      game['liked'] = false
    end
  end
  
  def self.search(query)
    igdb_id = Rails.application.credentials.igdb[:igdb_id]
    igdb_access_token = Rails.application.credentials.igdb[:igdb_access_token]
    body = "search \"#{query.to_s}\";
            where parent_game = null;
            fields id, name, cover.url, first_release_date, platforms.abbreviation;
            limit 100;"

    HTTParty.post(
      'https://api.igdb.com/v4/games/',
      :body => body,
      :headers => {
        "Client-ID": igdb_id,
        Authorization: "Bearer #{igdb_access_token}"
      }
    ).parsed_response
  end
end
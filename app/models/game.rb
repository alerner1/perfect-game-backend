class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :user_played_games
  has_many :played_users, through: :user_played_games, :source => :user
  serialize :platforms

  def self.get_popular_games
    igdb_id = Rails.application.credentials.igdb[:igdb_id]
    igdb_access_token = Rails.application.credentials.igdb[:igdb_access_token]

    games_info = HTTParty.post(
      'https://api.igdb.com/v4/games/', 
      :body => 'fields id, name, cover.url, first_release_date, platforms.abbreviation;
               sort total_rating desc;
               where total_rating != null & total_rating_count > 300 & parent_game = null & name != "The Last of Us Remastered";
               limit 25;',
      :headers => {
        "Client-ID": igdb_id,
        Authorization: "Bearer #{igdb_access_token}"
      },
    ).parsed_response

    games_info.each do |game|
      game['first_release_date'] = Time.at(game['first_release_date']).to_datetime.strftime('%Y')
      if game['cover'] != nil
        split_img_url = game['cover']['url'].split('t_thumb')
        game['cover']['url'] = split_img_url.join('t_1080p')
      end
      game['liked'] = false
      game['igdb_id'] = game['id']
      game.delete('id')
    end
  end
  
  def self.search(query)
    igdb_id = Rails.application.credentials.igdb[:igdb_id]
    igdb_access_token = Rails.application.credentials.igdb[:igdb_access_token]
    body = "search \"#{query.to_s}\";
            where parent_game = null;
            fields id, name, cover.url, first_release_date, platforms.abbreviation;
            limit 100;"

    search_results = HTTParty.post(
      'https://api.igdb.com/v4/games/',
      :body => body,
      :headers => {
        "Client-ID": igdb_id,
        Authorization: "Bearer #{igdb_access_token}"
      }
    ).parsed_response
    search_results.each do |result|
      result['first_release_date'] = Time.at(result['first_release_date']).to_datetime.strftime('%Y') unless result['first_release_date'] == nil
      if result['cover'] != nil
        split_img_url = result['cover']['url'].split('t_thumb')
        result['cover']['url'] = split_img_url.join('t_1080p')
      end
      result['igdb_id'] = result['id']
      result.delete('id')
    end
  end

  def self.get_quick_recs
    igdb_id = Rails.application.credentials.igdb[:igdb_id]
    igdb_access_token = Rails.application.credentials.igdb[:igdb_access_token]
    games_info = HTTParty.post(
      'https://api.igdb.com/v4/games',
      :body => 'fields id, name, cover.url, first_release_date, platforms.abbreviation;
                sort total_rating desc;
                limit 10;',
      :headers => {
        "Client-ID": igdb_id,
        Authorization: "Bearer #{igdb_access_token}"
      }
    ).parsed_response

    games_info.each do |game|
      game['first_release_date'] = Time.at(game['first_release_date']).to_datetime.strftime('%Y') unless game['first_release_date'] == nil
      if game['cover'] != nil
        split_img_url = game['cover']['url'].split('t_thumb')
        game['cover']['url'] = split_img_url.join('t_1080p')
        game['cover_url'] = game['cover']['url']
        game.delete('cover')
        game['igdb_id'] = game['id']
        game.delete('id')
      end
    end
  end
end
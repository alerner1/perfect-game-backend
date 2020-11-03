class MultiplayerMode < ApplicationRecord
  has_many :game_multiplayer_modes
  has_many :games, through: :game_multiplayer_modes

  IGDB_ID = Rails.application.credentials.igdb[:igdb_id]
  IGDB_ACCESS_TOKEN = Rails.application.credentials.igdb[:igdb_access_token]
  BASE_URL = "https://api.igdb.com/v4"
  HEADERS = {
    "Client-ID": IGDB_ID,
    Authorization: "Bearer #{IGDB_ACCESS_TOKEN}",
  }


  def self.create_multiplayer_modes
    modes = ["campaigncoop", "dropin", "game", "lancoop", "offlinecoop", "onlinecoop", "splitscreen", "splitscreenonline"]

    modes.each do |mode|
      MultiplayerMode.find_or_create_by(name: mode)
    end
  end

  def self.sorted_by_name
    self.all.sort_by do |multiplayer_mode|
      multiplayer_mode.name
    end
  end
end

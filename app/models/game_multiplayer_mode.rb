class GameMultiplayerMode < ApplicationRecord
  belongs_to :game
  belongs_to :multiplayer_mode
end

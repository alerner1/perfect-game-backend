class Api::V1::GamesController < ApplicationController
  skip_before_action :authorized
  def popular
    render json: Game.get_popular_games
  end
end
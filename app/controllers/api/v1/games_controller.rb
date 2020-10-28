class Api::V1::GamesController < ApplicationController
  skip_before_action :authorized
  def popular
    render json: Game.get_popular_games
  end

  def search
    render json: Game.search(params[:game][:query])
  end

  private

  # not sure if we actually need this?
  def games_params
    params.require(:game).permit(:query)
  end
end
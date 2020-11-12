class Api::V1::GamesController < ApplicationController
  skip_before_action :authorized
  def popular
    render json: Game.get_popular_games
  end

  def search
    games = Game.search(params[:game][:query])
    games.each do |game|
      if game["cover_url"] == nil
        game["cover_url"] = 'https://www.brdtex.com/wp-content/uploads/2019/09/no-image-480x480.png'
      end
    end
    render json: games
  end

  def quick_recommendations
    games = Game.get_quick_recs(current_user)
    games.each do |game|
      if game["cover_url"] == nil
        game["cover_url"] = 'https://www.brdtex.com/wp-content/uploads/2019/09/no-image-480x480.png'
      end
    end
    render json: games
  end

  def advanced_recommendations
    games = Game.get_advanced_recs(current_user, params)
    games.each do |game|
      if game["cover_url"] == nil
        game["cover_url"] = 'https://www.brdtex.com/wp-content/uploads/2019/09/no-image-480x480.png'
      end
    end
    render json: games
  end

  private

  # not sure if we actually need this?
  def games_params
    params.require(:game).permit(:query)
  end
end
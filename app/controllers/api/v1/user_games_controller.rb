class Api::V1::UserGamesController < ApplicationController

  def create
    @game = Game.find_or_create_by(igdb_id: params[:game][:igdb_id])
    @game.update(name: params[:game][:name], cover_url: params[:game][:cover_url], platforms: params[:game][:platforms])
    # the game_id thing below is going to get confusing. adjust attributes of Game to fix.
    @user_game = UserGame.find_or_create_by(user_id: current_user.id, game_id: @game.id, list: params[:user_game][:list])
    
    if @user_game.valid?
      render json: @user_game, status: :created
    else
      render json: { error: 'failed to add game' }, status: :not_acceptable
    end
  end

  private

  def user_game_params
    params.require(:user_game).permit(:user_id, :game_id, :list)
  end

  def game_params
    params.require(:game).permit(:igdb_id, :name, :cover_url, :release_date, platforms: [:abbreviation])
  end
end
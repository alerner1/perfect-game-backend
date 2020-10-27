class Api::V1::UserPlayedGamesController < ApplicationController

  def create
    @game = Game.find_or_create_by(rawg_id: params[:game_id])
    
    # the game_id thing below is going to get confusing. adjust attributes of Game to fix.
    @user_played_game = UserPlayedGame.find_or_create_by(user_id: current_user.id, game_id: @game.id, liked: params[:liked])
    
    if @user_played_game.valid?
      render json: @user_played_game, status: :created
    else
      render json: { error: 'failed to add liked game' }, status: :not_acceptable
    end
  end

  private

  def user_played_game_params
    params.require(:user_played_game).permit(:game_id, :liked)
  end
end
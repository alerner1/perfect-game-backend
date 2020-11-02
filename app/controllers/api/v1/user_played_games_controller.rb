class Api::V1::UserPlayedGamesController < ApplicationController

  def create
    @game = Game.find_by(igdb_id: params[:game][:igdb_id])
    # the game_id thing below is going to get confusing. adjust attributes of Game to fix.
    @user_played_game = UserPlayedGame.find_or_create_by(user_id: current_user.id, game_id: @game.id)
    @user_played_game.update(liked: params[:liked])
    
    if @user_played_game.valid?
      render json: @user_played_game, status: :created
    else
      render json: { error: 'failed to add liked game' }, status: :not_acceptable
    end
  end

  def update
    user_played_game = UserPlayedGame.find(params[:id])
    user_played_game.update(user_played_game_params)
    if user_played_game.save
      render json: { user_played_game: user_played_game }, status: :accepted
    else
      render json: { error: 'failed to update user played game' }, status: :not_acceptable
    end
  end

  def destroy
    user_played_game = UserPlayedGame.find(params[:id])
    user_played_game.destroy
    if user_played_game.destroyed?
      render json: { user_played_game: 'destroyed' }, status: :accepted
    else
      render json: { error: 'unable to destroy' }, status: :not_acceptable
    end
  end

  private

  def user_played_game_params
    params.require(:user_played_game).permit(:user_id, :game_id, :liked)
  end

  def game_params
    params.require(:game).permit(:igdb_id, :name, :cover_url, :release_date, platforms: [:abbreviation])
  end
end



# t.integer :igdb_id
# t.string :name
# t.string :cover_url
# t.string :release_date
# t.string :platforms
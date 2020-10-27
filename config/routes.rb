Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      resources :user_played_games
      post '/login', to: 'auth#create'
      get '/profile', to: 'users#profile'
      get '/games/popular', to: 'games#popular'
    end
  end
end
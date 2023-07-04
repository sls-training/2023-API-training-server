Rails.application.routes.draw do
  resources :items, as: :files, only: %i[create]
  resource :user, only: %i[create]
  resource :access_token, as: :signin, only: %i[create]
  resource :access_token_revocations, as: :signout, only: %i[create]
end

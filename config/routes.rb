Rails.application.routes.draw do
  post 'user', to: 'users#create'
  post 'signin', to: 'access_tokens#create'
  resource :access_token_revocations, as: :signout, only: %i[create]
end

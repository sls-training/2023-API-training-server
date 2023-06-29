Rails.application.routes.draw do
  post 'user', to: 'users#create'
  post 'signin', to: 'access_tokens#create'
  resource :access_tokens, as: :signout, only: %i[destroy]
end

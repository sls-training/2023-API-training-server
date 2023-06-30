Rails.application.routes.draw do
  post 'user', to: 'users#create'
  post 'signin', to: 'access_tokens#create'
end

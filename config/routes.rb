Rails.application.routes.draw do
  post 'user', to: 'users#post'
  post 'signin', to: 'access_tokens#post'
end

Rails.application.routes.draw do
  post 'user', to: 'users#post'
end

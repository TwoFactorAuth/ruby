Rails.application.routes.draw do
  devise_for :users
  two_factor_auth_for :users
  root to: 'secrets#index'
end

Rails.application.routes.draw do
  devise_for :users
  fido_login_for :users
  root to: 'secrets#index'

  #mount FidoLogin::Engine => "/fido_login"
end

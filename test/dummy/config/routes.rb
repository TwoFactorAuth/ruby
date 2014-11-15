Rails.application.routes.draw do

  mount FidoLogin::Engine => "/fido_login"
end

class FidoLogin::FidoLoginController < ApplicationController
  include Devise::Controllers::Helpers

  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def after_fido_login_registration_path_for(resource)
    signed_in_root_path(resource)
  end

  def after_fido_login_authentication_path_for(resource)
    after_sign_in_path_for(resource)
  end
end

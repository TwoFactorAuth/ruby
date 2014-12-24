module TwoFactorAuth
  class TwoFactorAuthController < ApplicationController
    include TwoFactorAuth::ApplicationHelper
    include Devise::Controllers::Helpers

    protect_from_forgery with: :exception
    before_action :authenticate_user!

    private

    def after_two_factor_auth_registrations_path_for(resource)
      signed_in_root_path(resource)
    end

    def after_two_factor_auth_authentication_path_for(resource)
      after_sign_in_path_for(resource)
    end
  end
end

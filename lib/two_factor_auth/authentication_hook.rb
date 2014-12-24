module TwoFactorAuth
  module AuthenticationHook
    include TwoFactorAuth::ApplicationHelper

    before_action :two_factor_auth_authentication

    private

    def two_factor_auth_authentication
      if user_signed_in? and !user_two_factor_auth_authenticated?
        redirect_to new_two_factor_auth_authentication_path
        return false
      end
      true
    end
  end
end


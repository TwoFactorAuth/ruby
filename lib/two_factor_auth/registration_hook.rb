module TwoFactorAuth
  module RegistrationHook
    include TwoFactorAuth::ApplicationHelper

    before_action :two_factor_auth_registration

    private

    def two_factor_auth_registration
      if user_signed_in? and !user_two_factor_auth_registered?
        redirect_to new_two_factor_auth_registrations_path
        return false
      end
      true
    end
  end
end

module FidoLogin
  module RegistrationHook
    include FidoLogin::ApplicationHelper

    before_action :fido_login_registration

    private

    def fido_login_registration
      if user_signed_in? and !user_fido_registered?
        redirect_to new_fido_login_registrations_path
        return false
      end
      true
    end
  end
end

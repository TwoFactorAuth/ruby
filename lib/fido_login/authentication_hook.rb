module FidoLogin
  module AuthenticationHook
    include FidoLogin::ApplicationHelper

    before_action :fido_login_authentication

    private

    def fido_login_authentication
      if user_signed_in? and !user_fido_authenticated?
        redirect_to new_fido_login_authentication_path
        return false
      end
      true
    end
  end
end


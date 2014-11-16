module FidoLogin
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    before_action :fido_login_registration
    before_action :fido_login_authentication

    private

    def fido_login_registration
      if user_signed_in? and !user_fido_registered?
        redirect_to new_fido_login_registration_path
        return false
      end
      true
    end

    def fido_login_authentication
      if user_signed_in? and !user_fido_authenticated?
        redirect_to new_fido_login_authentication_path
        return false
      end
      true
    end

    def user_fido_registered?
      current_user.registrations.any?
    end

    def user_fido_authenticated?
      user_session['fido_authenticated'].present?
    end

    def user_fido_authenticated! counter
      Registration.authenticated(current_user, counter)
      user_session['fido_authenticated'] = Time.now
    end
  end
end

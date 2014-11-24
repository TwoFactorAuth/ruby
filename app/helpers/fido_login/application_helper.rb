module FidoLogin
  module ApplicationHelper
    def user_fido_registered?
      current_user.registrations.any?
    end

    def user_fido_authenticated! counter
      Registration.authenticated(current_user, counter)
      user_session['fido_authenticated'] = Time.now
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

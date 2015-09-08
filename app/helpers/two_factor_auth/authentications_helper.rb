module TwoFactorAuth
  module AuthenticationsHelper
    def two_factor_auth_authentication
      if user_signed_in? and !user_two_factor_auth_authenticated?
        redirect_to new_two_factor_auth_authentication_path
        return false
      end
      true
    end

    def user_two_factor_auth_authenticated?
      user_session['two_factor_auth_authenticated'].present?
    end

    def user_two_factor_auth_authenticated! counter
      Registration.authenticated(current_user, counter)
      user_session['two_factor_auth_authenticated'] = Time.now
    end

    def user_two_factor_auth_authenticated! counter
      Registration.authenticated(current_user, counter)
      user_session['two_factor_auth_authenticated'] = Time.now
    end

    def authentication_request
      @authentication_request ||= AuthenticationRequest.new(
        TwoFactorAuth.trusted_facet_list_url,
        Registration.key_handle_for_authentication(current_user),
        user_session['pending_authentication_request_challenge']
      )
      user_session['pending_authentication_request_challenge'] = @authentication_request.challenge
      @authentication_request
    end

    def clear_pending_authentication_challenge
      @authentication_request = nil
      user_session.delete 'pending_authentication_request_challenge'
    end
  end
end

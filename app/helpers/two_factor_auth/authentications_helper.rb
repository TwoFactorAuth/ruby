module TwoFactorAuth
  module AuthenticationsHelper
    def authentication_request
      @authentication_request ||= AuthenticationRequest.new(
        TwoFactorAuth.trusted_facet_list_url,
        Registration.key_handle_for_authentication(current_user),
        user_session['pending_authentication_request_challenge']
      )
      user_session['pending_authentication_request_challenge'] = @authentication_request.challenge
      @authentication_request
    end

    def clear_pending_challenge
      @authentication_request = nil
      user_session.delete 'pending_authentication_request_challenge'
    end
  end
end

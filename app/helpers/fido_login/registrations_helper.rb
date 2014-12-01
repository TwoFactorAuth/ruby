module FidoLogin
  module RegistrationsHelper
    def registration_request
      @registration_request ||= RegistrationRequest.new(
        FidoLogin.trusted_facet_list_url,
        [],
        user_session['pending_registration_request_challenge']
      )
      user_session['pending_registration_request_challenge'] = @registration_request.challenge
      @registration_request
    end

    def clear_pending_challenge
      user_session.delete 'pending_registration_request_challenge'
    end
  end
end

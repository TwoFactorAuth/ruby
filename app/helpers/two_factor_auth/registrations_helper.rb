module TwoFactorAuth
  module RegistrationsHelper
    def user_two_factor_auth_registered?
      current_user.registrations.any?
    end

    def two_factor_auth_registration
      if user_signed_in? and !user_two_factor_auth_registered?
        redirect_to new_two_factor_auth_registrations_path
        return false
      end
      true
    end

    def registration_request
      @registration_request ||= RegistrationRequest.new(
        TwoFactorAuth.trusted_facet_list_url,
        [],
        user_session['pending_registration_request_challenge']
      )
      user_session['pending_registration_request_challenge'] = @registration_request.challenge
      @registration_request
    end

    def clear_pending_registration_challenge
      @registration_request = nil
      user_session.delete 'pending_registration_request_challenge'
    end
  end
end

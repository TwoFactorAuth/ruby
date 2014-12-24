module TwoFactorAuth
  class RegistrationsController < TwoFactorAuthController
    skip_before_action :two_factor_auth_registration
    skip_before_action :two_factor_auth_authentication

    include TwoFactorAuth::RegistrationsHelper

    def new
    end

    def create
      verifier = RegistrationVerifier.new({
        login: current_user,
        request: registration_request,
        client_data: ClientData.new(encoded: params[:clientData], correct_typ: 'navigator.id.finishEnrollment'),
        response: RegistrationResponse.new(encoded: params[:registrationData]),
      })
      clear_pending_challenge

      if verifier.save
        user_two_factor_auth_authenticated! 0 # don't need to auth again after registration
        redirect_to after_two_factor_auth_registrations_path_for(current_user)
      else
        flash[:alert] = "Unable to register"
        render :new, status: 406
      end
    end
  end
end

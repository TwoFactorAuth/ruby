module FidoLogin
  class RegistrationsController < FidoLogin::FidoLoginController
    skip_before_action :fido_login_registration
    skip_before_action :fido_login_authentication

    include FidoLogin::RegistrationsHelper

    def new
    end

    def create
      @verifier = RegistrationVerifier.new({
        login: current_user,
        request: registration_request,
        client_data: ClientData.new(encoded: params[:clientData], correct_typ: 'navigator.id.finishEnrollment'),
        response: RegistrationResponse.new(encoded: params[:registrationData]),
      })
      clear_pending_challenge

      if @verifier.save
        user_fido_authenticated! 0 # don't need to auth again after registration
        redirect_to after_fido_login_registration_path_for(current_user)
      else
        flash[:alert] = "Unable to register"
        render :new, status: 406
      end
    end
  end
end

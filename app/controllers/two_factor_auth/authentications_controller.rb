module TwoFactorAuth
  class AuthenticationsController < TwoFactorAuthController
    skip_before_action :two_factor_auth_registration
    skip_before_action :two_factor_auth_authentication

    include TwoFactorAuth::AuthenticationsHelper

    def new
      redirect_to after_sign_in_path_for(current_user) if user_two_factor_auth_authenticated?
    end

    def create
      keyHandle = TwoFactorAuth::websafe_base64_decode(params.fetch(:keyHandle, ''))
      registration = Registration.find_by_key_handle(keyHandle)

      verifier = AuthenticationVerifier.new({
        registration: registration,
        request: authentication_request,
        client_data: ClientData.new(encoded: params[:clientData], correct_typ: 'navigator.id.getAssertion'),
        response: AuthenticationResponse.new(encoded: params[:signatureData]),
      })
      clear_pending_challenge

      if verifier.valid?
        user_two_factor_auth_authenticated! verifier.counter
        redirect_to after_sign_in_path_for(current_user)
      else
        flash[:alert] = "Unable to authenticate"
        render :new, status: 406
      end
    end
  end
end

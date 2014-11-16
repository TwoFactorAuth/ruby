module FidoLogin
  class AuthenticationsController < ApplicationController
    skip_before_action :fido_login_authentication

    include FidoLogin::AuthenticationsHelper

    def new
      redirect_to after_sign_in_path_for(current_user) if user_fido_authenticated?
    end

    def create
      keyHandle = FidoLogin::websafe_base64_decode(params.fetch(:keyHandle, ''))
      registration = Registration.find_by_key_handle(keyHandle)

      verifier = AuthenticationVerifier.new({
        registration: registration,
        request: authentication_request,
        client_data: ClientData.new(encoded: params[:clientData], correct_typ: 'navigator.id.getAssertion'),
        response: AuthenticationResponse.new(encoded: params[:signatureData]),
      })
      clear_pending_challenge

      if verifier.valid?
        user_fido_authenticated! verifier.counter
        redirect_to after_sign_in_path_for(current_user)
      else
        flash[:alert] = "Unable to authenticate - did you use the right device?"
        render :new, status: 406
      end
    end
  end
end

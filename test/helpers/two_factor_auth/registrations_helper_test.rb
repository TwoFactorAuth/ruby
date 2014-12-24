require 'test_helper'

module TwoFactorAuth
  describe RegistrationsHelper do
    describe "#registration_request" do
      def user_session
        {}
      end

      it "creates RegistrationRequests" do
        registration_request.must_be_instance_of RegistrationRequest
      end

      it "persists the challenge in the request" do
        ch1 = registration_request.challenge
        ch2 = registration_request.challenge
        ch1.must_equal ch2
      end
    end

    describe "#registration_request with pending challenge" do
      let(:encoded_challenge) { TwoFactorAuth.websafe_base64_encode('0' * 32) }
      def user_session
        {
          'pending_registration_request_challenge' => encoded_challenge
        }
      end
      it "uses pending challenge" do
        registration_request.challenge.must_equal encoded_challenge
      end
    end

  end
end

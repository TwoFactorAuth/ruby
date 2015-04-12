require_relative "../../test_helper"

module TwoFactorAuth
  describe AuthenticationsHelper do
    def current_user
      @current_user ||= User.create! email: 'user@example.com', password: 'password'
    end

    before do
      Registration.create!({
        login: current_user,
        key_handle: "key handle",
        public_key: "public key",
        certificate: "certificate",
        counter: 0,
        last_authenticated_at: Time.now,
      })
    end

    after do
      User.delete_all
    end

    describe "#authentication_request" do
      def user_session
        {}
      end

      it "creates AuthenticationRequests" do
        authentication_request.must_be_instance_of AuthenticationRequest
      end

      it "persists the challenge in the request" do
        ch1 = authentication_request.challenge
        ch2 = authentication_request.challenge
        ch1.must_equal ch2
      end
    end

    describe "#authentication_request with pending challenge" do
      let(:encoded_challenge) { TwoFactorAuth.websafe_base64_encode('0' * 32) }
      def user_session
        {
          'pending_authentication_request_challenge' => encoded_challenge
        }
      end

      it "uses pending challenge" do
        authentication_request.challenge.must_equal encoded_challenge
      end
    end

  end
end

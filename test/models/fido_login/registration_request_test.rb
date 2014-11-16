require 'test_helper'

module FidoLogin
  describe RegistrationRequest do
    let(:app_id) { 'http://fidologin.example.com/' }

    it "holds app id" do
      rr = RegistrationRequest.new('http://id.example.com/')
      rr.app_id.must_equal 'http://id.example.com/'
    end

    it "creates random challenges" do
      rr1 = RegistrationRequest.new(app_id)
      rr2 = RegistrationRequest.new(app_id)
      rr1.challenge.wont_equal rr2.challenge
    end

    it "uses the challenge given" do
      encoded_challenge = FidoLogin.websafe_base64_encode('0' * 32)
      rr = RegistrationRequest.new(app_id, [], encoded_challenge)
      rr.challenge.must_equal encoded_challenge
    end

    it "does not return Signs without KeyHandles" do
      rr = RegistrationRequest.new(app_id)
      rr.signs.must_equal []
    end
  end
end

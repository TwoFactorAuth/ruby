require 'test_helper'

module FidoLogin
  describe AuthenticationRequest do
    let(:app_id) { 'http://fidologin.example.com' }
    let(:key_handle) { FidoLogin.websafe_base64_decode "W9G8D38l_29TSKdejU57l4YZsTVeRUUHSuBenSHZ-J_hwL7YI1R_MN20OQETXmWy_tdVDBAnxAct8ys_R-h7cw" }

    it "holds app id" do
      ar = AuthenticationRequest.new('http://id.example.com', key_handle)
      ar.app_id.must_equal 'http://id.example.com'
    end

    it 'holds key handle' do
      ar = AuthenticationRequest.new('http://id.example.com', 'key handle')
      ar.key_handle.must_equal 'key handle'
    end

    it "creates random challenges" do
      ar1 = AuthenticationRequest.new(app_id, key_handle)
      ar2 = AuthenticationRequest.new(app_id, key_handle)
      ar1.challenge.wont_equal ar2.challenge
    end

    it "uses the challenge given" do
      encoded_challenge = FidoLogin.websafe_base64_encode('0' * 32)
      ar = AuthenticationRequest.new(app_id, key_handle, encoded_challenge)
      ar.challenge.must_equal encoded_challenge
    end

    it 'encodes the key handle when serialized' do
      ar = AuthenticationRequest.new('http://id.example.com', 'key handle')
      ar.serialized.must_include '"a2V5IGhhbmRsZQ"'
    end
  end
end

require 'test_helper'

module TwoFactorAuth
  describe AuthenticationVerifier do
    #parallelize_me!

    let(:app_id) { "http://local.twofactorauth.com:3000" }
    let(:key_handle) { TwoFactorAuth.websafe_base64_decode "fNKqlc0cHr7CcAScmiwJF3qL5WP5YY9vSZR5i474rPWmg8qjTHIckZA_v2Xioj6RB6BNJqzxUVUwG6wfksKXtA" }
    let(:challenge) { "i6M5PrWJbrwwn_25MqHJzbWVdILVCBfg1nLIiVJ_zOs" }
    let(:request) { AuthenticationRequest.new(app_id, key_handle, challenge) }
    let(:registration) { Registration.new({
      key_handle: key_handle,
      public_key: "\x049\xC6GC\xE6\xD3un;a\xD2\x04\e\x9B,vk\xEB\xDC\xB51\b\x14\x16\a\x92\x8D\xA1\xA92\xD7Z\x17\xB3D\xDF}P\xDA\x9Cg\xEB\xFD7h)N\xC4\xF2\xF1\x10\e\x8A\xC7\x88\x9AM\x17V\xEA\xBEX\x14\xAB".force_encoding('ASCII-8BIT'),
      certificate: "0\x82\x02\x1C0\x82\x01\x06\xA0\x03\x02\x01\x02\x02\x04$\xDB\xAB@0\v\x06\t*\x86H\x86\xF7\r\x01\x01\v0.1,0*\x06\x03U\x04\x03\x13#Yubico U2F Root CA Serial 4572006310 \x17\r140801000000Z\x18\x0F20500904000000Z0+1)0'\x06\x03U\x04\x03\f Yubico U2F EE Serial 135032778880Y0\x13\x06\a*\x86H\xCE=\x02\x01\x06\b*\x86H\xCE=\x03\x01\a\x03B\x00\x04\x02\xB0\x94\xBE4}GyA\xC4w\x8E\xBE\xC5\xCAM\xED*G\x9F\xAA\x1Eo\xEC9\xAF\xEB\xDE\f p\xCB[\xD4\xBDi\xC9jx\xE3\xBF\x87Q\xFE\xB5y\e\x8D\xFA\xCA\xC2\x94\x01u\x1C\xB1W\xB9|\t\xE49\x1A6\xA3\x120\x100\x0E\x06\n+\x06\x01\x04\x01\x82\xC4\n\x01\x01\x04\x000\v\x06\t*\x86H\x86\xF7\r\x01\x01\v\x03\x82\x01\x01\x00\xA3c\xAE\x0E\x98:\xF3\v\xBA\xF1,\x8B-\xF3ZY\xBF\x1C\xBBJ\e\x0F\xCBh\xC4\x84U\x84\x90\xF6\x874Xe\xB8\xDB\x02i\xC3F\xE5S\x88L,V\a\xAF\x0E\xA2{\x90\xAC\x8C\xF1\xEFC\x1Fr\xAC\x18\x9D\xB2\x1C\x82I\x14\xBF\x17\x88\xA5Q\x1A3\xD0{L\x8E4d|\xE9\xF6\x1E\x15\x16\xA9\xA9\xB3n\x90\n@ a\xF6\x9A\xA4n\x12\xC52\xB9\x93\xF9B>\xFA\xAAL\xF9\xA3\xB6T\xB4\xDD\xDE\xF2\x92JT\x8F\xD5\x99\x95Q\r\xD4\xF7\xF4\xD9\xA4\xD5!\x93\x87<q\xC9\xB8~\x86\x85>\x9E-\xA7^\x8F\fm(0St\xD4\xEF\xDD^\x14\x96\xF8\xC39\x06\x10{\xD6\x8B\xD65\r\xAA\xD2\xC3x\x11\xEC\xA3\xCAC\xBC\x93\vs@\x97\xDE\xF6\x9Dh\x8D\x94U\fL\xFB\x18\xA9\xE2K\x86\xA2\xE5\xD8\x8FI\x98\x99\xA0\x9B\xCE[\x81\fSl\xAF9\r\xC8\xBD\xDE\x96\r\xF30\xCA\xCA\xBC\x05!\xA1\x83#\x95\x7F\xFE\xBC\xA5\x9C\xA9\v \xB1\r\t\xB5#\x1CX\xC2~\xBAg\x83".force_encoding('ASCII-8BIT'),
      counter: 0,
    }) }
    let(:client_data) { ClientData.new encoded: "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZ2V0QXNzZXJ0aW9uIiwiY2hhbGxlbmdlIjoiaTZNNVByV0picnd3bl8yNU1xSEp6YldWZElMVkNCZmcxbkxJaVZKX3pPcyIsIm9yaWdpbiI6Imh0dHA6Ly9sb2NhbC5maWRvbG9naW4uY29tOjMwMDAiLCJjaWRfcHVia2V5IjoiIn0", correct_typ: 'navigator.id.getAssertion' }
    let(:signatureData) { "AQAAAAcwRQIhAKCimZ21ZEsqVRLkDW2MRlDVFLFFAdCsvCPRTRCzD_brAiBDrE3KuTNanagb1UtW2YM7tUqwIS-D_MK_EWvVsA-8xQ" }
    let(:response) { AuthenticationResponse.new(encoded: signatureData) }
    let(:verifier) { AuthenticationVerifier.new({
      registration: registration,
      request: request,
      client_data: client_data,
      response: response,
    }) }

    describe '#application_parameter' do
      it "is the sha256 hash of the app id" do
        verifier.application_parameter.must_equal "Nh\xA3j\x7F\xB2\xEE\xD6D\x1F\x18\t\xF1\xAEL\t\x7F\fjo\n\x80\xDE\xAD{\x9E\x13\x04\xAE\xFD.\xD6".force_encoding('ASCII-8BIT')
      end
    end

    describe '#challenge_parameter' do
      it "is the sha256 hash of the base64 decoded json string" do
        verifier.challenge_parameter.must_equal "\x92F\xAAS\t\x88Cxe\xD04E\xD7R\xCA)\x05\x1E\xAA\xCA\x18w\xC3\xBFfl\x17V1M\xC0\x95".force_encoding('ASCII-8BIT')
      end
    end

    describe '#digest' do
      it "combines fields to spec" do
        verifier.digest.must_equal "\fH\xF7\x81n41uT6kr\x7F$(\x06A\xF0\xE4\x96\xD6\x12\xB1U\x90\xA2\xB7\a\xBE]\xDF\xFA".force_encoding('ASCII-8BIT')
      end
    end

  #  describe '#signature_verified?' do
  #    it "is if the user's public key signed the digest to produce the signature" do
  #      verifier.signature_verified?(registration).must_equal true
  #    end
  #
  #    it "is not otherwise" do
  #      request = AuthenticationRequest.new "http://different.app.id", key_handle, challenge
  #      verifier = AuthenticationVerifier.new(request, clientData, response)
  #      verifier.signature_verified?(registration).must_equal false
  #    end
  #  end

    describe "validations" do
      it "is valid if everything is right" do
        verifier.valid?.must_equal true
      end

      it "is not if challenge doesn't match" do
        verifier.client_data.challenge = "different challenge"
        verifier.valid?.must_equal false
        verifier.errors.full_messages.join(' ').must_include 'challenge'
      end

      it "is not if origin doesn't match" do
        verifier.client_data.origin = "http://different.origin"
        verifier.valid?.must_equal false
        verifier.errors.full_messages.join(' ').must_include 'origin'
      end

      it "is not if counter doesn't advance" do
        verifier.registration.counter = 1
        verifier.response.counter = 1
        verifier.valid?.must_equal false
        verifier.errors.full_messages.join(' ').must_include 'counter'
      end
    end

  end
end

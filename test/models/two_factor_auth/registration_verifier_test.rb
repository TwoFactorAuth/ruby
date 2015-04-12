require_relative "../../test_helper"

module TwoFactorAuth
  describe RegistrationVerifier do
    #parallelize_me!

    let(:app_id) { "http://local.fidologin.com:3000" }
    let(:request) { RegistrationRequest.new(app_id, [], "5fxazqanRHtd7AtEHBGxxDpSj6mdBF26XF4xdA9m7Jw") }
    let(:client_data) { ClientData.new encoded: "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZmluaXNoRW5yb2xsbWVudCIsImNoYWxsZW5nZSI6IjVmeGF6cWFuUkh0ZDdBdEVIQkd4eERwU2o2bWRCRjI2WEY0eGRBOW03SnciLCJvcmlnaW4iOiJodHRwOi8vbG9jYWwuZmlkb2xvZ2luLmNvbTozMDAwIiwiY2lkX3B1YmtleSI6IiJ9", correct_typ: 'navigator.id.finishEnrollment' }
    let(:response) { RegistrationResponse.new encoded: "BQQqdFC3zhANYW9DmErAjFQYZjBExK22PLx-ViMOch04-wZ990aqOcF2gxS5gzSUDKzpPGXpliMk3UoXgYlC2QNuQGbQ4E5v_UrLCzT58SXg902p9JXmLboTF42QkuZXIbdea_97h96lVovJ7xrA-iWTrZiOSRVZoBZsTrCW64XMrUcwggIcMIIBBqADAgECAgQk26tAMAsGCSqGSIb3DQEBCzAuMSwwKgYDVQQDEyNZdWJpY28gVTJGIFJvb3QgQ0EgU2VyaWFsIDQ1NzIwMDYzMTAgFw0xNDA4MDEwMDAwMDBaGA8yMDUwMDkwNDAwMDAwMFowKzEpMCcGA1UEAwwgWXViaWNvIFUyRiBFRSBTZXJpYWwgMTM1MDMyNzc4ODgwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQCsJS-NH1HeUHEd46-xcpN7SpHn6oeb-w5r-veDCBwy1vUvWnJanjjv4dR_rV5G436ysKUAXUcsVe5fAnkORo2oxIwEDAOBgorBgEEAYLECgEBBAAwCwYJKoZIhvcNAQELA4IBAQCjY64OmDrzC7rxLIst81pZvxy7ShsPy2jEhFWEkPaHNFhluNsCacNG5VOITCxWB68OonuQrIzx70MfcqwYnbIcgkkUvxeIpVEaM9B7TI40ZHzp9h4VFqmps26QCkAgYfaapG4SxTK5k_lCPvqqTPmjtlS03d7ykkpUj9WZlVEN1Pf02aTVIZOHPHHJuH6GhT6eLadejwxtKDBTdNTv3V4UlvjDOQYQe9aL1jUNqtLDeBHso8pDvJMLc0CX3vadaI2UVQxM-xip4kuGouXYj0mYmaCbzluBDFNsrzkNyL3elg3zMMrKvAUhoYMjlX_-vKWcqQsgsQ0JtSMcWMJ-umeDMEUCIQCPkI4L_gHM88JrqJj_ZNRghQyC0gJyCC9RBrnfI2mDTwIgPOuEiD1AOfRaGO_EaHi-z4XyIGDhkG8-BYH-syVY5_o" }
    let(:verifier) { RegistrationVerifier.new({
      login: 'login placeholder',
      request: request,
      client_data: client_data,
      response: response,
    }) }

    describe '#application_parameter' do
      it "is the sha256 hash of the app id" do
        verifier.application_parameter.must_equal "Nh\xA3j\x7F\xB2\xEE\xD6D\x1F\x18\t\xF1\xAEL\t\x7F\fjo\n\x80\xDE\xAD{\x9E\x13\x04\xAE\xFD.\xD6".force_encoding('ASCII-8bit')
      end
    end

    describe '#challenge_parameter' do
      it "is the sha256 hash of the base64 decoded json string" do
        verifier.challenge_parameter.must_equal "\x05\xB4\xF4\x06\xDA\xF3So\xD9\x96\xB4XCSw\x93\xBFq\xDDS\xEE\x13NT\xB1\xFD\x88m\xF7\xCF\xB8|".force_encoding('ASCII-8bit')
      end
    end

    describe '#digest' do
      it "combines fields to spec" do
        verifier.digest.must_equal "\xFD\xED*TyGh\b\xD9\x01\x9A\x01ih\xF8/\x00\xA8\x98\x06\xD7~\x00s\x0F\x82h\xAA=\xD1\xAF\xA0".force_encoding('ASCII-8BIT')
      end
    end

    describe 'validation' do
      it 'is if response matches and signs request' do
        verifier.valid?.must_equal true
      end

      it 'is not if client_data is invalid' do
        verifier.client_data = ClientData.new encoded: "foo", correct_typ: 'navigator.id.finishEnrollment'
        verifier.valid?.must_equal false
        verifier.errors[:client_data].wont_be_empty
      end

      it 'is not if response is invalid' do
        verifier.response = RegistrationResponse.new encoded: "foo"
        verifier.valid?.must_equal false
        verifier.errors[:response].wont_be_empty
      end

      it 'is not if client challenge is different' do
        verifier.client_data.challenge = "wrong challenge"
        verifier.valid?.must_equal false
        verifier.errors[:client_data].wont_be_empty
      end

      it 'is not if client origin is different' do
        verifier.client_data.origin = "http://wrong.origin"
        verifier.valid?.must_equal false
        verifier.errors[:client_data].wont_be_empty
      end

      it 'is not if signature is invalid' do
        verifier.response.signature = "bad sig"
        verifier.valid?.must_equal false
        verifier.errors[:response].wont_be_empty
      end
    end

    describe "#registration_attributes returns attributes worth persisting for registration" do
      let(:attrs) { verifier.registration_attributes }

      it "has login" do
        attrs[:login].must_equal "login placeholder"
      end

      it "starts counter at zero" do
        attrs[:counter].must_equal 0
      end

      it "has key handle" do
        attrs[:key_handle].must_equal "f\xD0\xE0No\xFDJ\xCB\v4\xF9\xF1%\xE0\xF7M\xA9\xF4\x95\xE6-\xBA\x13\x17\x8D\x90\x92\xE6W!\xB7^k\xFF{\x87\xDE\xA5V\x8B\xC9\xEF\x1A\xC0\xFA%\x93\xAD\x98\x8EI\x15Y\xA0\x16lN\xB0\x96\xEB\x85\xCC\xADG".force_encoding('ASCII-8BIT')
      end

      it "has user's public key" do
        attrs[:public_key].must_equal "\x04*tP\xB7\xCE\x10\raoC\x98J\xC0\x8CT\x18f0D\xC4\xAD\xB6<\xBC~V#\x0Er\x1D8\xFB\x06}\xF7F\xAA9\xC1v\x83\x14\xB9\x834\x94\f\xAC\xE9<e\xE9\x96\#$\xDDJ\x17\x81\x89B\xD9\x03n".force_encoding('ASCII-8BIT')
      end

      it "has attestation certificate" do
        attrs[:certificate].must_equal  "0\x82\x02\x1C0\x82\x01\x06\xA0\x03\x02\x01\x02\x02\x04$\xDB\xAB@0\v\x06\t*\x86H\x86\xF7\r\x01\x01\v0.1,0*\x06\x03U\x04\x03\x13#Yubico U2F Root CA Serial 4572006310 \x17\r140801000000Z\x18\x0F20500904000000Z0+1)0'\x06\x03U\x04\x03\f Yubico U2F EE Serial 135032778880Y0\x13\x06\a*\x86H\xCE=\x02\x01\x06\b*\x86H\xCE=\x03\x01\a\x03B\x00\x04\x02\xB0\x94\xBE4}GyA\xC4w\x8E\xBE\xC5\xCAM\xED*G\x9F\xAA\x1Eo\xEC9\xAF\xEB\xDE\f p\xCB[\xD4\xBDi\xC9jx\xE3\xBF\x87Q\xFE\xB5y\e\x8D\xFA\xCA\xC2\x94\x01u\x1C\xB1W\xB9|\t\xE49\x1A6\xA3\x120\x100\x0E\x06\n+\x06\x01\x04\x01\x82\xC4\n\x01\x01\x04\x000\v\x06\t*\x86H\x86\xF7\r\x01\x01\v\x03\x82\x01\x01\x00\xA3c\xAE\x0E\x98:\xF3\v\xBA\xF1,\x8B-\xF3ZY\xBF\x1C\xBBJ\e\x0F\xCBh\xC4\x84U\x84\x90\xF6\x874Xe\xB8\xDB\x02i\xC3F\xE5S\x88L,V\a\xAF\x0E\xA2{\x90\xAC\x8C\xF1\xEFC\x1Fr\xAC\x18\x9D\xB2\x1C\x82I\x14\xBF\x17\x88\xA5Q\x1A3\xD0{L\x8E4d|\xE9\xF6\x1E\x15\x16\xA9\xA9\xB3n\x90\n@ a\xF6\x9A\xA4n\x12\xC52\xB9\x93\xF9B>\xFA\xAAL\xF9\xA3\xB6T\xB4\xDD\xDE\xF2\x92JT\x8F\xD5\x99\x95Q\r\xD4\xF7\xF4\xD9\xA4\xD5!\x93\x87<q\xC9\xB8~\x86\x85>\x9E-\xA7^\x8F\fm(0St\xD4\xEF\xDD^\x14\x96\xF8\xC39\x06\x10{\xD6\x8B\xD65\r\xAA\xD2\xC3x\x11\xEC\xA3\xCAC\xBC\x93\vs@\x97\xDE\xF6\x9Dh\x8D\x94U\fL\xFB\x18\xA9\xE2K\x86\xA2\xE5\xD8\x8FI\x98\x99\xA0\x9B\xCE[\x81\fSl\xAF9\r\xC8\xBD\xDE\x96\r\xF30\xCA\xCA\xBC\x05!\xA1\x83#\x95\x7F\xFE\xBC\xA5\x9C\xA9\v \xB1\r\t\xB5#\x1CX\xC2~\xBAg\x83".force_encoding('ASCII-8BIT')
      end
    end
  end
end

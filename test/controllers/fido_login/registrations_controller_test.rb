require "test_helper"

module FidoLogin
  describe RegistrationsController do
    let(:current_user) { User.create!(email: 'user@example.com', password: 'password') }
    let(:clientData) { "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZmluaXNoRW5yb2xsbWVudCIsImNoYWxsZW5nZSI6IjVmeGF6cWFuUkh0ZDdBdEVIQkd4eERwU2o2bWRCRjI2WEY0eGRBOW03SnciLCJvcmlnaW4iOiJodHRwOi8vbG9jYWwuZmlkb2xvZ2luLmNvbTozMDAwIiwiY2lkX3B1YmtleSI6IiJ9" }
    let(:registrationData) { "BQQqdFC3zhANYW9DmErAjFQYZjBExK22PLx-ViMOch04-wZ990aqOcF2gxS5gzSUDKzpPGXpliMk3UoXgYlC2QNuQGbQ4E5v_UrLCzT58SXg902p9JXmLboTF42QkuZXIbdea_97h96lVovJ7xrA-iWTrZiOSRVZoBZsTrCW64XMrUcwggIcMIIBBqADAgECAgQk26tAMAsGCSqGSIb3DQEBCzAuMSwwKgYDVQQDEyNZdWJpY28gVTJGIFJvb3QgQ0EgU2VyaWFsIDQ1NzIwMDYzMTAgFw0xNDA4MDEwMDAwMDBaGA8yMDUwMDkwNDAwMDAwMFowKzEpMCcGA1UEAwwgWXViaWNvIFUyRiBFRSBTZXJpYWwgMTM1MDMyNzc4ODgwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQCsJS-NH1HeUHEd46-xcpN7SpHn6oeb-w5r-veDCBwy1vUvWnJanjjv4dR_rV5G436ysKUAXUcsVe5fAnkORo2oxIwEDAOBgorBgEEAYLECgEBBAAwCwYJKoZIhvcNAQELA4IBAQCjY64OmDrzC7rxLIst81pZvxy7ShsPy2jEhFWEkPaHNFhluNsCacNG5VOITCxWB68OonuQrIzx70MfcqwYnbIcgkkUvxeIpVEaM9B7TI40ZHzp9h4VFqmps26QCkAgYfaapG4SxTK5k_lCPvqqTPmjtlS03d7ykkpUj9WZlVEN1Pf02aTVIZOHPHHJuH6GhT6eLadejwxtKDBTdNTv3V4UlvjDOQYQe9aL1jUNqtLDeBHso8pDvJMLc0CX3vadaI2UVQxM-xip4kuGouXYj0mYmaCbzluBDFNsrzkNyL3elg3zMMrKvAUhoYMjlX_-vKWcqQsgsQ0JtSMcWMJ-umeDMEUCIQCPkI4L_gHM88JrqJj_ZNRghQyC0gJyCC9RBrnfI2mDTwIgPOuEiD1AOfRaGO_EaHi-z4XyIGDhkG8-BYH-syVY5_o" }

    before do
      FidoLogin.trusted_facet_list_url = "http://local.fidologin.com:3000"
      sign_in current_user
    end

    describe "#new" do
      it "has a form linking to create" do
        get :new
        assert_response :success
        assert_select "form[action='/fido_login/registration']"
      end
    end

    describe "#create" do
      it "clears the pending challenge" do
        controller.stub(:user_session, { 'pending_registration_request_challenge' => '5fxazqanRHtd7AtEHBGxxDpSj6mdBF26XF4xdA9m7Jw' }) do
          post :create, clientData: clientData, registrationData: registrationData
          controller.user_session.wont_include 'pending_registration_request_challenge'
        end
      end

      describe "success" do

        it "creates a Registration when the challenge is verified" do
          controller.stub(:user_session, { 'pending_registration_request_challenge' => '5fxazqanRHtd7AtEHBGxxDpSj6mdBF26XF4xdA9m7Jw' }) do
            Registration.count.must_equal 0
            post :create, clientData: clientData, registrationData: registrationData
            assert_response :redirect
            assert_redirected_to '/'
            current_user.registrations.count.must_equal 1
          end
        end

      end

      describe "failure" do
        it "renders an error when challenge is not verified" do
          controller.stub(:user_session, { 'pending_registration_request_challenge' => 'not matched' }) do
            Registration.count.must_equal 0
            post :create, clientData: clientData, registrationData: registrationData
            response.status.must_equal 406
            Registration.count.must_equal 0
            response.body.must_include 'Unable to register'
          end
        end
      end
    end
  end
end

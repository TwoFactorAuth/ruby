require "test_helper"

module TwoFactorAuth
  describe AuthenticationsController do
    let(:current_user) { User.create!(email: 'user@example.com', password: 'password') }
    let(:registration) { Registration.create!({
      login: current_user,
      key_handle:  TwoFactorAuth.websafe_base64_decode("fNKqlc0cHr7CcAScmiwJF3qL5WP5YY9vSZR5i474rPWmg8qjTHIckZA_v2Xioj6RB6BNJqzxUVUwG6wfksKXtA"),
      public_key:  TwoFactorAuth.websafe_base64_decode("BDnGR0Pm03VuO2HSBBubLHZr69y1MQgUFgeSjaGpMtdaF7NE331Q2pxn6_03aClOxPLxEBuKx4iaTRdW6r5YFKs"),
      certificate: TwoFactorAuth.websafe_base64_decode("MIICHDCCAQagAwIBAgIEJNurQDALBgkqhkiG9w0BAQswLjEsMCoGA1UEAxMjWXViaWNvIFUyRiBSb290IENBIFNlcmlhbCA0NTcyMDA2MzEwIBcNMTQwODAxMDAwMDAwWhgPMjA1MDA5MDQwMDAwMDBaMCsxKTAnBgNVBAMMIFl1YmljbyBVMkYgRUUgU2VyaWFsIDEzNTAzMjc3ODg4MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEArCUvjR9R3lBxHeOvsXKTe0qR5-qHm_sOa_r3gwgcMtb1L1pyWp447-HUf61eRuN-srClAF1HLFXuXwJ5DkaNqMSMBAwDgYKKwYBBAGCxAoBAQQAMAsGCSqGSIb3DQEBCwOCAQEAo2OuDpg68wu68SyLLfNaWb8cu0obD8toxIRVhJD2hzRYZbjbAmnDRuVTiEwsVgevDqJ7kKyM8e9DH3KsGJ2yHIJJFL8XiKVRGjPQe0yONGR86fYeFRapqbNukApAIGH2mqRuEsUyuZP5Qj76qkz5o7ZUtN3e8pJKVI_VmZVRDdT39Nmk1SGThzxxybh-hoU-ni2nXo8MbSgwU3TU791eFJb4wzkGEHvWi9Y1DarSw3gR7KPKQ7yTC3NAl972nWiNlFUMTPsYqeJLhqLl2I9JmJmgm85bgQxTbK85Dci93pYN8zDKyrwFIaGDI5V__rylnKkLILENCbUjHFjCfrpngw"),
      counter: 3,
      last_authenticated_at: Time.now,
    }) }
    let(:challenge) { "430x3zbNg7tdHBds3_aXoSjp81xWe_2eZoEgR856tv8" }
    let(:clientData) { "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZ2V0QXNzZXJ0aW9uIiwiY2hhbGxlbmdlIjoiNDMweDN6Yk5nN3RkSEJkczNfYVhvU2pwODF4V2VfMmVab0VnUjg1NnR2OCIsIm9yaWdpbiI6Imh0dHA6Ly9sb2NhbC5maWRvbG9naW4uY29tOjMwMDAiLCJjaWRfcHVia2V5IjoiIn0" }
    let(:signatureData) { "AQAAABAwRgIhAPueB6u8s63myrtQBT7KNOR3c4CVoNPVAiEkSOB8WGzqAiEA5zYbDQopgsVUl3d3pC947pKFSSIJs00ouC3xn3m7Pxo" }

    before do
      TwoFactorAuth.trusted_facet_list_url = "http://local.twofactorauth.com:3000"
      register_as current_user, registration
    end

    describe "#new" do
      it "has a form linking to create" do
        get :new
        assert_response :success
        assert_select "form[action='/two_factor_auth/authentication']"
      end

      it "does not prompt for re-authentication if you already have" do
        authenticate_as current_user, registration
        get :new
        assert_response :redirect
      end
    end

    describe "#create" do
      it "clears the pending challenge" do
        controller.stub(:user_session, { 'pending_authentication_request_challenge' => challenge }) do
          post :create, keyHandle: TwoFactorAuth.websafe_base64_encode(registration.key_handle), clientData: clientData, signatureData: signatureData
          controller.user_session.wont_include 'pending_authentication_request_challenge'
        end
      end

      describe "success" do

        it "creates a Registration when the challenge is verified" do
          controller.stub(:user_session, { 'pending_authentication_request_challenge' => challenge }) do
            post :create, keyHandle: TwoFactorAuth.websafe_base64_encode(registration.key_handle), clientData: clientData, signatureData: signatureData
            assert_response :redirect
            assert_redirected_to '/'
            controller.send(:user_two_factor_auth_authenticated?).must_equal true
          end
        end

      end

      describe "failure" do
        it "renders an error when challenge is not verified" do
          controller.stub(:user_session, { 'pending_authentication_request_challenge' => 'not matched' }) do
            post :create, keyHandle: TwoFactorAuth.websafe_base64_encode(registration.key_handle), clientData: clientData, signatureData: signatureData
            controller.send(:user_two_factor_auth_authenticated?).must_equal false
            response.status.must_equal 406
            response.body.must_include 'Unable to authenticate'
          end
        end
      end
    end
  end
end

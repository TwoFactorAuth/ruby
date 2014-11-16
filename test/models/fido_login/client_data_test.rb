require 'test_helper'

module FidoLogin
  describe ClientData do
    #parallelize_me!

    let(:clientData) { "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZmluaXNoRW5yb2xsbWVudCIsImNoYWxsZW5nZSI6IjVmeGF6cWFuUkh0ZDdBdEVIQkd4eERwU2o2bWRCRjI2WEY0eGRBOW03SnciLCJvcmlnaW4iOiJodHRwOi8vbG9jYWwuZmlkb2xvZ2luLmNvbTozMDAwIiwiY2lkX3B1YmtleSI6IiJ9" }
    let(:client_data) { ClientData.new(encoded: clientData, correct_typ: 'navigator.id.finishEnrollment') }

    describe "decomposing attrs" do
      it "extracts the typ" do
        client_data.typ.must_equal "navigator.id.finishEnrollment"
      end

      it "extracts the challenge" do
        client_data.challenge.must_equal "5fxazqanRHtd7AtEHBGxxDpSj6mdBF26XF4xdA9m7Jw"
      end

      it "extracts the origin" do
        client_data.origin.must_equal "http://local.fidologin.com:3000"
      end
    end

    describe "validations" do
      it "is valid with all fields valid" do
        client_data.valid?.must_equal true
      end

      # I can't see a nice way to break these checks out of decompose_attrs and,
      # because ActiveModel is all about mutability, it flushes errors when
      # .valid? is called.
      #it "is not if encoding is invalid" do
      #  cd = ClientData.new(encoded: "bad encoded data", correct_typ: 'navigator.id.finishEnrollment')
      #  cd.valid?.must_equal false
      #  cd.errors[:encoded].wont_be_empty
      #end
      #
      #it "is not if json is invalid" do
      #  cd = ClientData.new(encoded: FidoLogin.websafe_base64_encode("{blah"), correct_typ: 'navigator.id.finishEnrollment')
      #  cd.valid?.must_equal false
      #  cd.errors[:json].wont_be_empty
      #end

      it "is not if a key is added" do
        client_data.attrs[:extra] = "pair"
        client_data.valid?.must_equal false
        client_data.errors[:attrs].wont_be_empty
      end

      it "is not if a key is missing" do
        client_data.attrs.delete('origin')
        client_data.valid?.must_equal false
        client_data.errors[:attrs].wont_be_empty
      end

      it "accepts two possible values for correct_typ" do
        cd = ClientData.new(encoded: clientData, correct_typ: 'navigator.id.finishEnrollment')
        cd.valid?
        cd.errors[:correct_typ].must_be_empty
        cd = ClientData.new(encoded: clientData, correct_typ: 'navigator.id.getAssertion')
        cd.valid?
        cd.errors[:correct_typ].must_be_empty
      end

      it "raises on construction without a correct_typ" do
        Proc.new {
          ClientData.new(encoded: clientData)
        }.must_raise ArgumentError
      end

      it "is not if typ is incorrect" do
        client_data.typ = "invalid typ"
        client_data.valid?.must_equal false
        client_data.errors[:typ].wont_be_empty
      end
    end

  end
end

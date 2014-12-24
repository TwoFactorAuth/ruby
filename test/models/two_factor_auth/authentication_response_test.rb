require 'test_helper'

module TwoFactorAuth
  describe AuthenticationResponse do
    #parallelize_me!

    let(:app_id) { "http://local.twofactorauth.io:3000" }
    let(:signatureData) { "AQAAAAUwRQIgaeZw29qOaQ50Wb4a7LjxV32_JR-Bru_0bPm0lIdrK1kCIQCl5_-Lssd4pzZ3tyaLIWIZEKhwZzwhceV2mHN2qzH3mw" }
    let(:response) { AuthenticationResponse.new(encoded: signatureData) }

    describe "decomposing fields" do
      it "extracts bitfield byte" do
        response.bitfield.must_equal 1
      end

      it "extracts counter" do
        response.counter.must_equal 5
      end

      it "extracts signature" do
        response.signature.must_equal "0E\x02 i\xE6p\xDB\xDA\x8Ei\x0EtY\xBE\x1A\xEC\xB8\xF1W}\xBF%\x1F\x81\xAE\xEF\xF4l\xF9\xB4\x94\x87k+Y\x02!\x00\xA5\xE7\xFF\x8B\xB2\xC7x\xA76w\xB7&\x8B!b\x19\x10\xA8pg<!q\xE5v\x98sv\xAB1\xF7\x9B".force_encoding('ASCII-8BIT')
        response.signature.length.must_equal 71
      end

      it "starts with signatureData a known size" do
        raw = TwoFactorAuth.websafe_base64_decode signatureData
        raw.length.must_equal 76
      end
    end

    describe "validation" do
      it "is when correct" do
        response.valid?.must_equal true
      end

      it "is not when bitfield is wrong" do
        response.bitfield = 8
        response.valid?.must_equal false
        response.errors[:bitfield].wont_be_empty
      end
    end

  end
end

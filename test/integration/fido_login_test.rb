require 'test_helper'

# not an integration spec, but it's easier to dump it here than convince Rails
# to check a new directory

describe FidoLogin do
  describe "U2F_VERSION" do
    it "is the only version" do
      FidoLogin::U2F_VERSION.must_equal 'U2F_V2'
    end
  end

  describe ".base64u_encode" do
    it "encodes data" do
      FidoLogin.websafe_base64_encode("foo").must_equal "Zm9v"
    end

    it "does not include trailing =s" do
      Base64.urlsafe_encode64("ab").must_equal "YWI="
      FidoLogin.websafe_base64_encode("ab").must_equal "YWI"
    end
  end
  
  describe ".base64u_decode" do
    it "decodes data" do
      FidoLogin.websafe_base64_decode("Zm9v").must_equal "foo"
    end

    it "does not mind missing trailing =s" do
      Base64.urlsafe_decode64("YWI=").must_equal "ab"
      FidoLogin.websafe_base64_decode("YWI").must_equal "ab"
    end
  end
end

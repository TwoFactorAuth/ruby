require_relative '../test_helper'

describe TwoFactorAuth do
  let(:pubkey) {  "\x049\xC6GC\xE6\xD3un;a\xD2\x04\e\x9B,vk\xEB\xDC\xB51\b\x14\x16\a\x92\x8D\xA1\xA92\xD7Z\x17\xB3D\xDF}P\xDA\x9Cg\xEB\xFD7h)N\xC4\xF2\xF1\x10\e\x8A\xC7\x88\x9AM\x17V\xEA\xBEX\x14\xAB" }

  def teardown
    # clear all the settings between runs
    TwoFactorAuth.instance_variable_set(:@facet_domain, nil)
    TwoFactorAuth.instance_variable_set(:@trusted_facet_list_url, nil)
    TwoFactorAuth.instance_variable_set(:@facets, nil)
  end

  describe "U2F_VERSION" do
    it "is the only version" do
      TwoFactorAuth::U2F_VERSION.must_equal 'U2F_V2'
    end
  end

  describe "setting facet_domain" do
    it "remembers what is set" do
      TwoFactorAuth.facet_domain = "https://www.example.net"
      TwoFactorAuth.facet_domain.must_equal "https://www.example.net"
    end

    it "normalizes to remove trailing /" do
      TwoFactorAuth.facet_domain = "https://www.example.net/"
      TwoFactorAuth.facet_domain.must_equal "https://www.example.net"
    end

    # Yes, after 5 hours of debugging to solve the vague error caused by this,
    # it deserves a redundant test.
    it "doesn't let http domains end in a /" do
      TwoFactorAuth.facet_domain = "http://www.example.net/"
      TwoFactorAuth.facet_domain.must_equal "http://www.example.net"
    end

    it "raises if you try to use something.dev" do
      Proc.new {
        TwoFactorAuth.facet_domain = "http://local.dev:3000"
      }.must_raise(TwoFactorAuth::InvalidFacetDomain)
      Proc.new {
        TwoFactorAuth.facet_domain = "http://local.dev:3000/"
      }.must_raise(TwoFactorAuth::InvalidFacetDomain)
      Proc.new {
        TwoFactorAuth.facet_domain = "http://local.dev/"
      }.must_raise(TwoFactorAuth::InvalidFacetDomain)
    end

    it "raises if you use the default from the initializer" do
      Proc.new {
        TwoFactorAuth.facet_domain = "https://www.example.com"
      }.must_raise(TwoFactorAuth::InvalidFacetDomain)
    end
  end

  describe "setting trusted_facet_list_url" do
    it "can be set explicitly" do
      TwoFactorAuth.trusted_facet_list_url = "https://www.example.net/facets"
      TwoFactorAuth.trusted_facet_list_url.must_equal "https://www.example.net/facets"
    end

    it "is based on facet_domain otherwise" do
      TwoFactorAuth.facet_domain = "https://www.example.net"
      TwoFactorAuth.trusted_facet_list_url.must_match /\Ahttps:\/\/www.example.net/
    end

    it "prohibits HTTP URLs" do
      Proc.new {
        TwoFactorAuth.trusted_facet_list_url = "http://www.example.net/list"
      }.must_raise(TwoFactorAuth::InvalidTrustedFacetListUrl)
    end
  end

  describe "#app_id_or_facet_list" do
    it "is the domain if there are no facets" do
      TwoFactorAuth.facet_domain = "https://www.example.net"
      TwoFactorAuth.facets = []
      TwoFactorAuth.app_id_or_facet_list.must_equal "https://www.example.net"
    end

    it "is the trusted facet list if there are facets" do
      TwoFactorAuth.facet_domain = "https://www.example.net"
      TwoFactorAuth.facets = ["https://www.example.com", "https://www.example.net"]
      TwoFactorAuth.app_id_or_facet_list.must_equal "https://www.example.net/two_factor_auth/trusted_facets"
    end
  end

  describe "setting facets" do
    it "can be set explicitly" do
      TwoFactorAuth.facet_domain = "https://www.example.net"
      TwoFactorAuth.facets = ["https://www.example.net", "https://staging.example.net"]
      TwoFactorAuth.facets.must_equal ["https://www.example.net", "https://staging.example.net"]
    end

    it "prohibits using a facet list with an http app id" do
      TwoFactorAuth.facet_domain = "http://www.example.net/"
      Proc.new {
        TwoFactorAuth.facets = ["https://www.example.com"]
      }.must_raise(TwoFactorAuth::InvalidFacetDomain)
    end

    it "prohibits setting an HTTP URL in the facet list" do
      TwoFactorAuth.facet_domain = "https://www.example.net/"
      Proc.new {
        TwoFactorAuth.facets = ["http://www.example.net"]
      }.must_raise(TwoFactorAuth::InvalidFacetListDomain)
    end

    it "is empty by default" do
      # this value is persisted across tests...
      TwoFactorAuth.facets = nil
      TwoFactorAuth.facet_domain = "https://www.example.net"
      TwoFactorAuth.facets.must_equal []
    end
  end

  describe ".websafe_base64u_encode" do
    it "encodes data" do
      TwoFactorAuth.websafe_base64_encode("foo").must_equal "Zm9v"
    end

    it "does not include trailing =s" do
      Base64.urlsafe_encode64("ab").must_equal "YWI="
      TwoFactorAuth.websafe_base64_encode("ab").must_equal "YWI"
    end
  end
  
  describe ".websafe_base64u_decode" do
    it "decodes data" do
      TwoFactorAuth.websafe_base64_decode("Zm9v").must_equal "foo"
    end

    it "does not mind missing trailing =s" do
      Base64.urlsafe_decode64("YWI=").must_equal "ab"
      TwoFactorAuth.websafe_base64_decode("YWI").must_equal "ab"
    end
  end

  describe "#random_encoded_challenge" do
    it "is 32 bytes, encoded" do
      challenge = TwoFactorAuth.random_encoded_challenge
      decoded = TwoFactorAuth.websafe_base64_decode(challenge)
      decoded.length.must_equal 32
    end

    it "is different every time" do
      c1 = TwoFactorAuth.random_encoded_challenge
      c2 = TwoFactorAuth.random_encoded_challenge
      c1.wont_equal c2
    end

    it "raises if out of entropy" do
      OpenSSL::Random.stub(:pseudo_bytes, Proc.new { raise OpenSSL::Random::RandomError }) do
        Proc.new {
          TwoFactorAuth.random_encoded_challenge
        }.must_raise TwoFactorAuth::CantGenerateRandomNumbers
      end
    end
  end

  describe "#decode_pubkey" do
    it "returns the Point" do
      point = TwoFactorAuth.decode_pubkey pubkey
      point.to_bn.to_i.must_equal 56657129115817956563260749049282610971311272788676140555509072492610442759820703941373942638593733546160471073247664666784884688116961061627926493680637099
    end

    it "raises if invalid" do
      Proc.new {
        TwoFactorAuth.decode_pubkey "invalid key"
      }.must_raise TwoFactorAuth::InvalidPublicKey
    end
  end

  describe "#pubkey_valid?" do
    it "is if key is valid" do
      b = TwoFactorAuth.pubkey_valid? pubkey
      b.must_equal true
    end

    it "is not if key is not a valid key" do
      b = TwoFactorAuth.pubkey_valid? "invalid key"
      b.must_equal false
    end

    # I'd like a second test for a well-structured key that is not on the
    # curve, but I can't see how to construct one; OpenSSL::PKey::EC::Point
    # raises "OpenSSL::PKey::EC::Point::Error: point is not on curve" if I try
    # to construct one.
  end
end

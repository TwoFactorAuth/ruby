require_relative "../../test_helper"

module TwoFactorAuth
  describe TrustedFacetsController do
    it "returns the list of facets as json" do
      TwoFactorAuth.facets = [ 'https://example.com', 'https://admin.example.com' ]
      get :index
      facets = JSON::parse(response.body)
      facets.must_equal TwoFactorAuth.facets
    end

    it "has the U2F mimetype" do
      get :index
      response.content_type.must_equal "application/fido.trusted-apps+json"
    end
  end
end

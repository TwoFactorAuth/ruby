module FidoLogin
  # Does not inherit from ApplicationController because many of those enforce
  # logins on all but a whitelist of pages and the U2F spec requires this
  # respond to a request with no cookies or other auth.
  class TrustedFacetsController < ActionController::Base
    def index
      render text: FidoLogin.facets.to_json, content_type: "application/fido.trusted-apps+json"
    end
  end
end

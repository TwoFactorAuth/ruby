require 'adamantium'

module TwoFactorAuth
  class RegistrationRequest
    include Adamantium

    attr_reader :app_id, :key_handles

    def initialize app_id=TwoFactorAuth.trusted_facet_list_url, key_handles=[], challenge=nil
      @app_id = app_id
      @key_handles = key_handles
      @challenge = challenge
    end

    def challenge
      @challenge || TwoFactorAuth::random_encoded_challenge
    end
    memoize :challenge

    def signs
      []
    end

    # this matches te browser's u2f api
    def serialized
      {
        appId: app_id,
        challenge: challenge,
        version: TwoFactorAuth::U2F_VERSION,
      }.to_json
    end
  end
end

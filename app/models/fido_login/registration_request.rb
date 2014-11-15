module FidoLogin
  class RegistrationRequest
    include Adamantium

    attr_reader :app_id, :key_handles

    def initialize app_id=FidoLogin::APP_ID, key_handles=[], challenge=nil
      @app_id = app_id
      @key_handles = key_handles
      @challenge = challenge
    end

    def challenge
      @challenge || FidoLogin::random_encoded_challenge
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
        version: FidoLogin::VERSION,
      }.to_json
    end
  end

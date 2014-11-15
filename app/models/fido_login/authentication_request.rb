module FidoLogin
  class AuthenticationRequest
    include Adamantium

    attr_reader :app_id, :key_handle

    def initialize app_id, key_handle, challenge=nil
      @app_id = app_id
      @key_handle = key_handle
      @challenge = challenge
    end

    def challenge
      @challenge || FidoLogin::random_encoded_challenge
    end
    memoize :challenge

    # this matches te browser's u2f api
    def serialized
      {
        appId: app_id,
        keyHandle: FidoLogin.websafe_base64_encode(key_handle),
        challenge: challenge,
        version: FidoLogin::VERSION,
      }.to_json
    end
  end
end

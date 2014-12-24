require 'active_model'
require 'virtus'

module TwoFactorAuth
  class AuthenticationVerifier
    include ActiveModel::Validations
    include Virtus.model

    attribute :registration, Registration
    attribute :request, AuthenticationRequest
    attribute :client_data, ClientData
    attribute :response, AuthenticationResponse

    validate :client_challenge_matches, :client_origin_matches,
            :counter_advances,
            :verify_signature
    validates_associated :client_data, :response

    def application_parameter
      OpenSSL::Digest::SHA256.new.digest(request.app_id.encode('ASCII-8BIT'))
    end

    def challenge_parameter
      OpenSSL::Digest::SHA256.new.digest(client_data.json)
    end

    def client_challenge_matches
      if client_data.challenge != request.challenge
        errors.add :client_data, "challenge does not match the challenge they were sent"
      end
    end

    def client_origin_matches
      if client_data.origin != request.app_id
        errors.add :client_data, "origin does not match the appId they were sent"
      end
    end

    def counter_advances
      if response.counter <= registration.counter
        errors.add :response, "does not advance counter - could mean device was cloned"
      end
    end

    def digest
      data = [
        application_parameter,
        response.bitfield.chr,
        [response.counter].pack('N'),
        challenge_parameter,
      ].join('')
      OpenSSL::Digest::SHA256.new.digest(data)
    end

    def verify_signature
      ec = OpenSSL::PKey::EC.new('prime256v1')
      ec.public_key = TwoFactorAuth.decode_pubkey registration.public_key
      return false if ec.public_key.nil?
      if !ec.dsa_verify_asn1(digest, response.signature)
        errors.add :response, "signature is not correct"
      end
    end

    def counter
      response.counter
    end
  end
end

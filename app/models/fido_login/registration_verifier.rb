require 'active_model'
require 'virtus'

module FidoLogin
  class RegistrationVerifier
    include ActiveModel::Validations
    #include FidoLogin::ValidateAssociated
    include Virtus.model

    attribute :login
    attribute :request, RegistrationRequest
    attribute :client_data, ClientData
    attribute :response, RegistrationResponse

    validates :request, :client_data, :response, presence: true
    validate :client_challenge_matches,
            :client_origin_matches,
            :verify_signature
    validates_associated :client_data, :response

    def application_parameter
      OpenSSL::Digest::SHA256.new.digest(request.app_id.encode('ASCII-8BIT'))
    end

    def challenge_parameter
      OpenSSL::Digest::SHA256.new.digest(client_data.json)
    end

    def digest
      data = [
        0.chr.encode('ASCII-8BIT'),
        application_parameter,
        challenge_parameter,
        response.key_handle,
        response.public_key,
      ].join('')
      OpenSSL::Digest::SHA256.new.digest(data)
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

    def verify_signature
      ec = OpenSSL::PKey::EC.new('prime256v1')
      ec.public_key = response.certificate_public_key
      return false if ec.public_key.nil?
      if !ec.dsa_verify_asn1(digest, response.signature)
        errors.add :response, "signature is not correct"
      end
    rescue TypeError # from certificate_public_key not extracting cert and using nil
      errors.add(:response, "certificate was not extracted")
    rescue OpenSSL::PKey::ECError # signature is invalid, not just incorrect
      errors.add(:response, "signature not valid")
    end

    def persisted? ; false ; end

    def save
      if valid?
        persist!
        true
      else
        false
      end
    end

    def registration_attributes
      {
        login: login,
        counter: 0,
        key_handle: response.key_handle,
        public_key: response.public_key,
        certificate: response.certificate,
        last_authenticated_at: Time.now,
      }
    end

    def persist!
      Registration.create!(registration_attributes)
    end
  end
end

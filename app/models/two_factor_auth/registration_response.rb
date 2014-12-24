require 'active_model'
require 'virtus'

# See FIDO U2F "Raw Message Formats" documentation, section 4.3 "Registration
# Response Message: Success"
module TwoFactorAuth
  class RegistrationResponse
    include ActiveModel::Validations
    include Virtus.model

    USER_PUBKEY_LENGTH = 65

    attribute :encoded, String
    attribute :raw, String

    attribute :reserved_byte, Fixnum
    attribute :public_key, String
    attribute :key_handle, String
    attribute :certificate, String
    attribute :signature, String

    validates :reserved_byte, :public_key, :key_handle, :certificate,
      :signature, presence: true
    validate :reserved_byte_correct, :certificate_valid,
            :certificate_trusted, :public_key_valid

    def initialize *args, &blk
      super
      decompose_fields if encoded.present?
    end

    def decompose_fields
      self.raw = TwoFactorAuth::websafe_base64_decode(encoded)
      io = StringIO.new raw

      self.reserved_byte = io.read(1)
      self.public_key = io.read(USER_PUBKEY_LENGTH)
      key_handle_length = io.readbyte
      self.key_handle = io.read(key_handle_length)

      at_peek = io.read(4)
      io.seek(-4, IO::SEEK_CUR)
      attestation_certificate_length = 4 + at_peek[2..3].unpack('n').first
      self.certificate = io.read(attestation_certificate_length)
      self.signature = io.read
    rescue ArgumentError => e
      errors.add(:encoded, "Can't decode base64: #{e.message}")
    rescue EOFError => e
      errors.add(:raw, "Can't extract all fields")
    end

    def certificate_public_key
      OpenSSL::X509::Certificate.new(certificate).public_key.public_key
    end

    def reserved_byte_correct
      if reserved_byte.ord != 5
        errors.add :reserved_byte, "must be 0x05"
      end
    end

    def certificate_valid
      OpenSSL::X509::Certificate.new(certificate)
    rescue TypeError # from certificate_public_key not extracting cert and using nil
      errors.add(:certificate, "was not extracted")
    rescue OpenSSL::X509::CertificateError
      errors.add :certificate, "not a valid x509 certificate"
    end

    def public_key_valid
      if !TwoFactorAuth.pubkey_valid?(public_key)
        errors.add :public_key, "not a valid public key"
      end
    end

    # FIDO raw message formats v1.0 page 5 says "The relying party should also
    # verify that the attestation certificate was issued by a trusted
    # certification authority. The exact process of setting up trusted
    # certification authorities is to be defined by the FIDO Alliance and is
    # outside the scope of this document."
    # This hasn't yet been defined and may turn out to only be a way for the
    # FIDO alliance to extract money from client creators. Or it may turn out to
    # be something that servers want to configure. So this is a placeholder
    # method to remind that this may be important in the future.
    def certificate_trusted
      true
    end

    def persisted? ; false ; end
  end
end

require 'active_model'
require 'virtus'

module FidoLogin
  class ClientData
    include ActiveModel::Validations
    include Virtus.model

    attribute :correct_typ, String
    attribute :encoded, String
    attribute :attrs, Hash

    attribute :json, String
    attribute :typ, String
    attribute :challenge, String
    attribute :origin, String
    attribute :cid_pubkey, String

    validates :correct_typ, :typ, :challenge, :origin, presence: true
    validates :correct_typ, inclusion: { in: %w{navigator.id.getAssertion navigator.id.finishEnrollment} }
    validate :client_data_has_correct_keys, :typ_correct

    def initialize *args, &blk
      super
      decompose_attrs if encoded.present?
      raise ArgumentError, "correct_typ is mandatory" if correct_typ.blank?
    end

    def decompose_attrs
      self.json = FidoLogin::websafe_base64_decode(encoded)
      self.attrs = JSON.parse(json)

      self.typ        = attrs['typ']
      self.challenge  = attrs['challenge']
      self.origin     = attrs['origin']
      self.cid_pubkey = attrs['cid_pubkey']
    rescue ArgumentError => e
      errors.add(:encoded, "Can't decode base64: #{e.message}")
    rescue JSON::ParserError => e
      errors.add(:json, "Can't parse json: #{e.message}")
    end

    def client_data_has_correct_keys
      if attrs.keys != %w{typ challenge origin cid_pubkey}
        errors.add :attrs, "has wrong keys: #{attrs.keys.join(', ')}"
      end
    end

    def typ_correct
      if typ != correct_typ
        errors.add :typ, "should be navigator.id.getAssertion but is #{typ}"
      end
    end

    def persisted? ; false ; end
  end
end

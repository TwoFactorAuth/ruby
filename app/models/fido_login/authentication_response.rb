# See Fido U2F "Raw Message Formats" documentation, section 4.3 "Registration
# Response Message: Success"
module FidoLogin
  class AuthenticationResponse
    include ActiveModel::Validations
    include Virtus.model

    attribute :encoded, String
    attribute :raw, String

    attribute :bitfield, Fixnum
    attribute :user_presence, Boolean
    attribute :counter, Fixnum
    attribute :signature, String

    validates :bitfield, :user_presence, :counter, :signature, presence: true
    validate :bitfield_correct, :user_is_present

    def initialize *args, &blk
      super
      decompose_fields
    end

    def decompose_fields
      self.raw = FidoLogin.websafe_base64_decode encoded
      io = StringIO.new raw

      @bitfield = io.read(1).ord
      @user_presence = @bitfield.ord & 1 == 1
      @counter = io.read(4).unpack("N").first
      @signature = io.read
    end

    def bitfield_correct
      if bitfield.ord != 1
        errors.add :bitfield, "bits 1-7 must be set to zero"
      end
    end

    def user_is_present
      if !user_presence
        errors.add :user_presence, "must be set"
      end
    end
  end
end

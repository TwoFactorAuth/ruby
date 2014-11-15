module FidoLogin
  class Registration < ActiveRecord::Base
    belongs_to :login, polymorphic: true

    validates :login, :key_handle, :public_key, :certificate, :counter, :last_authenticated_at, presence: true

    def self.key_handle_for_authentication login
      login.registrations.first.key_handle
    end

    def self.authenticated login, counter
      reg = login.registrations.first
      reg.last_authenticated_at = Time.now
      reg.counter = counter
      reg.save!
    end
  end
end

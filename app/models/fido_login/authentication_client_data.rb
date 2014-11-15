module FidoLogin
  class AuthenticationClientData < ClientData
    validate :typ_correct

    def typ_correct
      if typ != 'navigator.id.getAssertion'
        errors.add :typ, "should be navigator.id.getAssertion but is #{typ}"
      end
    end
  end
end

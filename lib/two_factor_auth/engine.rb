module TwoFactorAuth
  class Engine < ::Rails::Engine
    isolate_namespace TwoFactorAuth

    initializer 'two_factor_auth.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        include TwoFactorAuth::RegistrationsHelper
        include TwoFactorAuth::AuthenticationsHelper
      end
    end
  end
end

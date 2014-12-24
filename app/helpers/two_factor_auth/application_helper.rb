module TwoFactorAuth
  module ApplicationHelper
    def user_two_factor_auth_registered?
      current_user.registrations.any?
    end

    def user_two_factor_auth_authenticated! counter
      Registration.authenticated(current_user, counter)
      user_session['two_factor_auth_authenticated'] = Time.now
    end

    def user_two_factor_auth_authenticated?
      user_session['two_factor_auth_authenticated'].present?
    end

    def user_two_factor_auth_authenticated! counter
      Registration.authenticated(current_user, counter)
      user_session['two_factor_auth_authenticated'] = Time.now
    end
  end
end

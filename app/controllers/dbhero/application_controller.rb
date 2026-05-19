module Dbhero
  class ApplicationController < ActionController::Base
    def check_auth
      return unless Dbhero.authenticate
      return if _current_user && call_custom_auth

      head :forbidden
    end

    def user_representation
      _current_user.send(Dbhero.user_representation) if _current_user
    end

    def _current_user
      return unless Dbhero.authenticate && Dbhero.current_user_method.present?

      send(Dbhero.current_user_method)
    end

    def call_custom_auth
      cond = Dbhero.custom_user_auth_condition
      return true unless cond.is_a?(Proc)

      cond.call(_current_user)
    end
  end
end

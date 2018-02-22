module Dbhero
  module ApplicationHelper
    def html_class
      return "" if !current_user_super_admin?
      "grey lighten-3"
    end

    def current_user_super_admin?
      current_user&.has_role?(:super_admin)
    end
  end
end

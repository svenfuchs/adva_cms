module Rbac
  module RoleType
    module Static
      self.role_types = [:editor, :superuser, :moderator, :author, :user, :anonymous, :pizzaboy]
  
      module Pizzaboy
        extend Rbac::RoleType

        class << self
          def requires_context?
            true
          end
      
          def masters
            []
          end

          def minions
            []
          end
        end
      end
    end
  end
end
module Rbac
  module RoleType
    module Static
      mattr_accessor :role_types
      self.role_types = [:superuser, :designer, :moderator, :author, :user, :anonymous]
  
      class << self
        def build(name)
          const_get(name.to_s.camelize)
        end

        def all
          @role_types ||= role_types.map { |type| build(type) }
        end
      end
  
      module Anonymous
        extend Rbac::RoleType

        class << self
          def requires_context?
            false
          end
      
          def masters
            [User]
          end

          def minions
            []
          end

          def granted_to?(subject, context = nil, options = {})
            options[:explicit] ? false : true
          end
        end
      end

      module User
        extend Rbac::RoleType

        class << self
          def requires_context?
            false
          end
      
          def minions
            [Anonymous]
          end

          def masters
            [Author]
          end

          def granted_to?(subject, context = nil, options = {})
            options[:explicit] ? false : subject.registered?
          end
        end
      end

      module Author
        extend Rbac::RoleType

        class << self
          def minions
            [User]
          end

          def masters
            [Moderator]
          end

          def granted_to?(subject, context = nil, options = {})
            if options[:explicit]
              false
            else
              context.respond_to?(:author) && context.author == subject.object || super
            end
          end
        end
      end

      module Moderator
        extend Rbac::RoleType

        class << self
          def minions
            [Author]
          end

          def masters
            [Designer]
          end
        end
      end
      
      module Designer
        extend Rbac::RoleType

        class << self
          def minions
            [Moderator]
          end

          def masters
            [Admin]
          end
        end
      end

      module Admin
        extend Rbac::RoleType

        class << self
          def minions
            [Designer]
          end

          def masters
            [Superuser]
          end
        end
      end

      module Superuser
        extend Rbac::RoleType

        class << self
          def requires_context?
            false
          end
      
          def minions
            [Admin]
          end

          def masters
            []
          end
        end
      end
    end
  end
end

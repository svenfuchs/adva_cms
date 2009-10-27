module Rbac
  module RoleType
    module Author
      extend Rbac::RoleType

      class << self
        def minions
          [User]
        end

        def masters
          [Moderator]
        end

        def granted_to?(user, context = nil, options = {})
          options[:explicit] ? false : context.respond_to?(:author) && context.author == user || super
        end
      end
    end

    module Static
      mattr_accessor :role_types
      self.role_types = [:editor, :superuser, :moderator, :author, :user, :anonymous]

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

          def granted_to?(user, context = nil, options = {})
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
            [Editor, Author]
          end

          def granted_to?(user, context = nil, options = {})
            options[:explicit] ? false : user.try(:registered?)
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

          def granted_to?(user, context = nil, options = {})
            options[:explicit] ? false : context.respond_to?(:author) && context.author == user || super
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
            [Moderator, Editor]
          end

          def masters
            []
          end
        end
      end

      module Editor
        extend Rbac::RoleType

        class << self
          def minions
            [User]
          end

          def masters
            [Superuser]
          end
        end
      end
    end
  end
end

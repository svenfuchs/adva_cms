module Rbac
  module RoleType
    mattr_accessor :implementation

    class << self
      def build(*args)
        implementation.build(*args)
      end
      
      def types
        implementation.all
      end
      
      def implementation
        @@implementation || raise(NoImplementation.new)
      end
    end
    
    def name
      super.split('::').last.underscore
    end
    
    def expand(object)
      expansion = [name]
      expansion += [object.class.to_s.underscore, object.id] if requires_context?
      expansion.join('-')
    end
    
    def requires_context?
      true
    end

    def self_and_masters
      [self] + all_masters
    end

    def masters
      []
    end

    def all_masters
      masters + masters.map(&:all_masters).flatten.uniq
    end

    def self_and_minions
      [self] + all_minions
    end

    def minions
      []
    end

    def all_minions
      minions + minions.map(&:all_minions).flatten.uniq
    end

    def minion_of?(name)
      self_and_masters.any? { |type| type.name == name }
    end

    def included_in?(role, context = nil)
      minion_of?(role.name) && (!role.context || role.context.role_context.include?(context))
    end

    def granted_to?(subject, context = nil, options = {})
      # this implementaion makes the assumption that subject implements an roles
      # method returning objects that carry the role's type/name and context
      !!subject.roles.detect do |role|
        options[:explicit] ? self.name == role.name : self.included_in?(role, context)
      end
    end
  end
end
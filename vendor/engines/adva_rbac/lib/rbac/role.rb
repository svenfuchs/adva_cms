module Rbac
  module Role
    class << self
      def define(name, options = {})
        parent = const_get options[:parent].to_s.classify if options[:parent]
        parent ||= Rbac::Role::Base
        klass = Class.new(parent)
        const_set(name.to_s.classify, klass).class_eval do
          self.granter = options[:grant]
          self.requires_context = options[:requires_context]
        end
      end
      
      def build(name, options = {})
        context = options[:context].role_context if options[:context]
        const_get(name.to_s.classify).new context
      end
    end
    
    class Base
      attr_reader :context
      class_inheritable_accessor :granter, :requires_context
      self.requires_context = false
      
      def initialize(context = nil)
        @context = context 
        raise "role #{self.class.name} needs a context" if requires_context and !context
      end
      
      def include?(role)
        self.is_a?(role.class) && (!has_context or !role.has_context or self.context.include?(role.context))
      end
      
      def has_context
        !!self.context
      end
      
      def granted_to?(user)
        case granter
        when true, false
          granter
        when Symbol
          user.send granter
        when Proc
          granter.call context, user
        end || !!user.roles.detect{|role| role.include? self }
      end
    end
  end
end
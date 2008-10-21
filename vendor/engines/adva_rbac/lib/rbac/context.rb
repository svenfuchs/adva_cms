module Rbac
  module Context
    mattr_accessor :permissions
    
    class << self
      def root
        @root ||= Base.new(self)
      end
    end
    
    class Base
      class_inheritable_accessor :options
      self.options = {}
      
      class_inheritable_accessor :children
      self.children = []
      
      class << self
        def inherited(child_class)
          self.children << child_class
        end
        
        def all_actions
          actions + all_children.map(&:actions).flatten
        end
        
        def actions
          options[:actions] ||= []
        end
    
        def roles
          options[:roles] ||= []
        end
    
        def parent
          superclass
        end
    
        def all_children
          children + children.map(&:all_children).flatten
        end
    
        def children
          options[:children] ||= []
        end
      end

      attr_reader :subject

      def initialize(subject = nil)
        @subject = subject
      end
      
      def include?(context)
        return false unless context
        begin 
          return true if subject == context.subject
        end while context = context.parent
        false
      end
    
      def parent
        if options[:parent]
          subject.send(options[:parent]).role_context
        elsif self != Rbac::Context.root
          Rbac::Context.root
        end
      end
        
      def role_authorizing(action)
        # TODO should return a Role object here instead of this
        permissions[action] || parent.try(:role_authorizing, action)
      end
      
      def permissions
        subject.try(:permissions) || {}
      end

      # def role_authorizing(action, type = nil)
      #   type ||= self.class.name.demodulize.downcase.to_sym
      #   role = permissions[type][action] if respond_to?(:permissions) && permissions[type]
      #   returning Role.build(role, self) || owner && owner.role_authorizing(action, type) do |role|
      #     raise "could not find role for #{type}: #{action} (on: #{self.inspect})" unless role
      #     role.original_context = self
      #   end
      # end
    end
  end
end
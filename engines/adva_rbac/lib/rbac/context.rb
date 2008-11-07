module Rbac
  module Context
    mattr_accessor :permissions
    
    class << self
      def root
        @root ||= Base.new(self)
      end
      
      def create_class(name, parent, options)
        returning Class.new(Rbac::Context::Base) do |klass|
          Rbac::Context.const_set(name, klass)
          klass.class_eval do
            self.options = options
            self.parent = parent
          end
        end
      end
    end
    
    class Base
      class_inheritable_accessor :parent, :parent_accessor, :options, :children
      self.options, self.children = {}, []
      
      class << self
        def all_actions
          actions + all_children.map(&:actions).flatten
        end
        
        def actions
          options[:actions] ||= []
        end
    
        def roles
          options[:roles] ||= []
        end
        
        def self_and_parents
          @self_and_parents ||= [self] + all_parents
        end
        
        def all_parents
          [parent] + (parent != Base ? Array(parent.try(:all_parents)) : [])
        end
    
        def all_children
          self.children + self.children.map(&:all_children).flatten
        end
    
        def children
          options[:children] ||= []
        end
      
        def parent=(parent)
          self.parent.children -= [self] if self.parent
          write_inheritable_attribute :parent, parent.try(:role_context_class) || Rbac::Context::Base
          self.parent.children << self
          self.parent_accessor = parent.name.underscore.to_sym if parent # TODO make this more flexible
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
        if parent_accessor
          subject.send(parent_accessor).role_context
        elsif self != Rbac::Context.root
          Rbac::Context.root
        end
      end

      def role_authorizing(action)
        Rbac::Role.build role_authorizing_name(action), :context => self
      end
      
      protected
      
        def role_authorizing_name(action)
          permissions[action.to_sym] || 
          parent.try(:role_authorizing_name, action) || 
          raise("could not find role for #{action} (on: #{self.inspect})")
        end
      
        def permissions
          permissions = subject.try(:permissions) || {}
          permissions.symbolize_keys
        end
    end
  end
end
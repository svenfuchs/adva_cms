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
        
        def self_and_parents
          [self] + all_parents
        end
        
        def all_parents
          [superclass] + (superclass != Base ? Array(superclass.try(:all_parents)) : [])
        end
    
        def parent
          superclass
        end
    
        def all_children
          self.children + self.children.map(&:all_children).flatten
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
        if permissions[action]
          begin
            Rbac::Role.build permissions[action], :context => self
          rescue
            raise "could not find role for #{action} (on: #{self.inspect})"
          end
        else
          parent.try(:role_authorizing, action)
        end
      end
      
      def permissions
        subject.try(:permissions) || {}
      end
    end
  end
end
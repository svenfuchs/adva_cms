module Rbac
  module Role
    class << self
      def define(name, options = {})
        parent = const_get options[:parent].to_s.camelize if options[:parent]
        require_context = options[:require_context]

        if require_context.respond_to?(:role_context_class)
          require_context = require_context.role_context_class
        elsif ![NilClass, FalseClass, TrueClass].include?(require_context.class)
          raise "class #{require_context.inspect} does not act_as_role_context"
        end

        message = options[:message]
        message = I18n.t(message) if message.is_a?(Symbol)
        
        parent ||= Rbac::Role::Base
        const_set(name.to_s.camelize, Class.new(Rbac::Role::Base)).class_eval do
          self.parent = parent
          self.parent.children << self
          self.require_context = require_context
          self.grant = options[:grant]
          self.message = message
        end
      end

      def build(name, options = {})
        const_get(name.to_s.camelize).new options
      end
    end

    class Base < ActiveRecord::Base
      self.store_full_sti_class = true
      # instantiates_with_sti
      set_table_name 'roles'

      belongs_to :user
      belongs_to :context, :polymorphic => true

      class_inheritable_accessor :parent, :require_context, :grant, :message
      self.require_context = false
      
      class << self
        attr_writer :children
      
        def self_and_parents
          @self_and_parents ||= [self] + all_parents
        end
      
        def all_parents
          [parent] + (parent != Base ? Array(parent.try(:all_parents)) : [])
        end
      
        def with_children
          [self] + all_children
        end
      
        def children
          @children ||= []
        end
      
        def all_children
          children + children.map(&:all_children).flatten
        end
      
        def role_name
          @role_name ||= name.demodulize.downcase.to_sym
        end
      end
      
      def initialize(attrs = {})
        super()
        if self.class.require_context
          if attrs[:context].blank? and !(attrs['context_type'].blank? or attrs['context_id'].blank?)
            attrs[:context] = attrs['context_type'].constantize.find(attrs['context_id'])
          end
          attrs ||= {}
          valid_context = attrs[:context] && attrs[:context] != Rbac::Context.root
          self.context = adjust_context(attrs[:context]) if valid_context
          raise "role #{self.class.name} needs a context" if require_context and !context
        end
      end
      
      def name
        self.class.role_name
      end
      
      def child_of?(klass)
        self.class.self_and_parents.include?(klass)
      end
      
      def include?(role)
        child_of?(role.class) && (!has_context? or !role.has_context? or context.role_context.include?(role.context.role_context))
      end
      
      def ==(role)
        instance_of?(role.class) && (!has_context? or !role.has_context? or context == role.context)
      end
      
      def has_context?
        !!context
      end
      
      def expand(context)
        self.class.with_children.map do |klass|
          klass.new :context => context
        end.compact
      end
      
      def granted_to?(user, options = {})
        !!case grant
        when true, false
          grant
        when Symbol
          user.send grant
        when Proc
          grant.call context, user
        end || explicitely_granted_to?(user, options)
      end
      
      protected
        def adjust_context(context)
          context = context.role_context unless context.is_a? Rbac::Context::Base
          bubble = context.class.self_and_parents.include?(require_context)
          begin
            return context.subject if !bubble or require_context == context.class
          end while context = context.parent
        end
      
        def explicitely_granted_to?(user, options = {})
          return false unless user.respond_to? :roles
          options[:inherit] = true unless options.has_key?(:inherit)
          !!user.roles.detect{|role| options[:inherit] ? role.include?(self) : role == self }
        end
    end
  end
end
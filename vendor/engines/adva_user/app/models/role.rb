class Role < ActiveRecord::Base
  self.store_full_sti_class = true
  
  attr_reader :name
  class_inheritable_accessor :has_context, :message, :children
  
  belongs_to :user
  belongs_to :context, :polymorphic => true
    
  class << self
    def inherited(klass)
      (self.children ||= []) << klass
      superclass.inherited(klass) unless self == Role
    end
    
    def with_children
      [self] + children
    end
    
    def names
      children.map{|klass| klass.role_name.to_s.camelize}.reverse
    end
    
    def build(name, context = nil)
      return name if name.nil? || name.is_a?(Role)
      const_get(name.to_s.classify).new :context => context
    end
    
    def role_name
      @role_name ||= name.demodulize.downcase.to_sym
    end
  end
  
  def initialize(*args)
    super
    self.context = adjusted_context(name) if self.class.has_context
  end
  
  def includes?(role)
    self.is_a?(role.class) && (!has_context || self.context == role.adjusted_context(name))
  end
  
  def ==(role)
    self.instance_of?(role.class) && (!has_context || self.context == role.context)
  end
  
  def name
    self.class.role_name
  end
  
  def expand(options = {})
    self.class.with_children.map do |klass|
      next unless options[:all] || klass.has_context
      Role.build klass.role_name, context
    end.compact
  end
  
  def parent
    Role.build self.class.superclass.role_name, context
  end
  
  def to_css_class
    context_type ? [context_type, context_id, name].join('-').downcase : name
  end
  
  def message
    self.class.message || begin
      article = %(a e i o u).include?(name.to_s[0, 1].downcase) ? 'an' : 'a'
      "You need to be #{article} #{name} to perform this action."        
    end
  end
  
  protected
  
    def adjusted_context(name)
      context.role_context(name) if context
    end
  
  class Anonymous < Role
    def applies_to?(user)
      true
    end
  end
  
  class User < Anonymous
    self.message = 'You need to be logged in to perform this action.'
    
    def applies_to?(user)
      user.registered?
    end
  end

  class Author < User
    self.has_context = true
    self.message = 'You need to be the author of this object to perform this action.'

    def applies_to?(user)
      context.respond_to?(:is_author?) && context.is_author?(user)
    end
  end

  class Moderator < Author 
    self.has_context = true
  end

  class Admin < Moderator
    self.has_context = true
  end

  class Superuser < Admin  
    self.has_context = false
  end 
end
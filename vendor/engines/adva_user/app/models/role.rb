class Role < ActiveRecord::Base
  self.store_full_sti_class = true
  instantiates_with_sti
  
  attr_accessor :name, :original_context
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

  # need to keep the original context because we need it for expanding the included roles
  def initialize(*args)
    super
    self.original_context = context
    self.context = adjusted_context(name)
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
      # next unless options[:all] || klass.has_context
      Role.build klass.role_name, original_context
    end.compact
  end
  
  def parent
    Role.build self.class.superclass.role_name, context
  end
  
  def to_default_css_class
    context_type ? [context_type, context_id, name].join('-').downcase : name
  end
  
  def message(action = nil, type = nil)
    self.class.message || begin
      article = %(a e i o u).include?(name.to_s[0, 1].downcase) ? 'an' : 'a'
      "You need to be #{article} #{name} to perform this action."        
    end
  end
  
  protected
  
    def adjusted_context(name)
      context.role_context(name) if self.class.has_context && context
    end
  
  class Anonymous < Role
    def applies_to?(user)
      true
    end
  
    def to_css_class
      'anonymous'
    end
  end
  
  class User < Anonymous
    self.message = 'You need to be logged in to perform this action.'
    
    def applies_to?(user)
      user.registered?
    end
  
    def to_css_class
      'user'
    end
  end

  class Author < User
    self.has_context = true
    self.message = 'You need to be the author of this object to perform this action.'

    def applies_to?(user)
      context = self.context || original_context
      context.respond_to?(:is_author?) && context.is_author?(user)
    end
  
    def to_css_class
      [context.author_type.underscore, context.author_id].join('-') + ' ' + to_default_css_class
    end
  end

  class Moderator < Author 
    self.has_context = true
  
    def to_css_class
      to_default_css_class
    end
  end

  class Admin < Moderator
    self.has_context = true

    # TODO would this work? - also for moderators and superusers
    # def applies_to?(user)
    #   context = self.context || original_context
    #   context.respond_to?(:is_admin?) && context.is_admin?(user)
    # end
  
    def to_css_class
      to_default_css_class
    end
  end

  class Superuser < Admin  
    self.has_context = false
  
    def to_css_class
      # TODO superusers are allowed to do everything, so we don't need to state this explicitely
      'superuser'
    end
  end 
end
# no idea, yet
#
# class Permission
#   @@permissions = %w(
#     sites.manage sections.manage
#     wiki.pages
#     wiki.pages.delete
#   )
#   cattr_reader :permissions
# end

class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :object, :polymorphic => true
  
  class << self
    def definition(name)
      "Role::Roles::#{name.to_s.camelize}".constantize
      # p name.to_s.camelize
      # Roles.const_get name.to_s.camelize
    end
    
    def names
      # Roles.constants TODO this doesn't keep a sane order
      %w(Superuser Admin Author User Anonymous) # Moderator
    end
  end
  
  def definition
    @definition ||= Role.definition(name)
  end
  
  def includes?(name, object = nil)
    definition.includes?(name) && (!definition.references_object? || references?(object))
  end
  
  def is?(name, object = nil)
    self.name == name.to_s && (object.nil? || references?(object))
  end
  
  def references?(object)
    attributes['object_id'] == object.id && object_type == object.class.name
  end
  
  # UMMMM ... NOT ... SURE ... YET ... REALLY.
  #
  # this uses modules for multiple role inheritance (e.g. admin might inherit both 
  # editor and moderator)
  
  module Roles
    module Anonymous    
      def role_required_message
        name = self.name.demodulize.downcase
        article = %(a e i o u).include?(name[0, 1].downcase) ? 'an' : 'a'
        "You need to be #{article} #{name} to perform this action."        
      end
    
      def includes?(other)
        other = Role.definition(other) unless other.is_a? Module
        self == other || self.include?(other)
      end
    
      def references_object?
        false
      end
    end
  
    module User
      extend Anonymous
      def self.role_required_message
        'You need to be logged in to perform this action.'
      end
    end
  
    module Author
      extend Anonymous
      @@name = 'author'
      def self.role_required_message
        'You need to be the author of this object to perform this action.'
      end
    end
  
    module Moderator
      extend Anonymous
      include User, Author
    
      def references_object?
        true
      end
    end
  
    module Admin
      extend Anonymous
      include Moderator
    end
  
    module Superuser
      extend Anonymous
      include Admin
    
      def references_object?
        false
      end
    end  
  
    # class Custom < ActiveRecord::Base
    #   # dynamically create user defined roles (?)
    # end
  end
end


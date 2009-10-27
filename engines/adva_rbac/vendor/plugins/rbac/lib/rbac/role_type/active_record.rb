require 'activerecord'

module Rbac
  module RoleType
    module ActiveRecord
      class RoleTypeRelationship < ::ActiveRecord::Base
        belongs_to :master, :class_name => "RoleType"
        belongs_to :minion, :class_name => "RoleType"
      end


      class RoleType < ::ActiveRecord::Base
        include Rbac::RoleType
        
        has_many :master_relationships, :foreign_key => 'master_id', :class_name => 'RoleTypeRelationship', :dependent => :destroy
        has_many :minion_relationships, :foreign_key => 'minion_id', :class_name => 'RoleTypeRelationship', :dependent => :destroy

        has_many :masters, :through => :minion_relationships
        has_many :minions, :through => :master_relationships
        
        class << self
          def build(name)
            find_by_name(name.to_s) || raise(Rbac::UndefinedRoleType.new(name))
          end
        end

        def requires_context?
          !!attributes['requires_context']
        end

        def granted_to?(user, context = nil, options = {})
          return super unless ['anonymous', 'user', 'author'].include?(name)
          return false if options[:explicit]

          case name
          when 'anonymous'
            true
          when 'user'
            user.try(:registered?)
          when 'author'
            context.respond_to?(:author) && context.author == user || super
          end
        end
      end
    end
  end
end
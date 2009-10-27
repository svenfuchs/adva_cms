ActionController::Dispatcher.to_prepare do
  Site.acts_as_role_context
  Section.acts_as_role_context :parent => :site
  Content.acts_as_role_context :parent => :section
  # Comment.acts_as_role_context :parent => :commentable

  # CalendarEvent.acts_as_role_context :parent => :section  if Rails.plugin?(:adva_calendar)
  # Photo.acts_as_role_context :parent => :section          if Rails.plugin?(:adva_photos)

  # if Rails.plugin?(:adva_forum)
  #   Board.acts_as_role_context :parent => :section
  #   Topic.acts_as_role_context :parent => :section
  # end

  Rbac::Role.class_eval do
    belongs_to :ancestor_context, :polymorphic => true

    before_save do |role|
      role.ancestor_context = role.context.owners.detect do |context|
        context.is_a?(Site) || context.is_a?(Account)
      end if role.context
    end
  end

  Account.class_eval do
    def members
      User.members_of(self).exclude_role_types('author', 'user')
    end
  end

  Site.class_eval do
    def members
      User.members_of(self)
    end
  end

  User.class_eval do
    named_scope :members_of, lambda { |context|
      {
        :include => :roles,
        :conditions => "(roles.ancestor_context_type = '#{context.class}' AND roles.ancestor_context_id = #{context.id}) OR
                        (roles.context_type = '#{context.class}' AND roles.context_id = #{context.id})"
      }
    }

    named_scope :by_role_types, lambda { |*role_types|
      { 
        :include => :roles, 
        :conditions => ["roles.name IN (?)", role_types]
      }
    }

    named_scope :exclude_role_types, lambda { |*role_types|
      { 
        :include => :roles, 
        :conditions => ["roles.name NOT IN (?)", role_types]
      }
    }
  end
end
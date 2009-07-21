ActionController::Dispatcher.to_prepare do
  Site.acts_as_role_context
  Section.acts_as_role_context :parent => :site
  Content.acts_as_role_context :parent => :section
  Comment.acts_as_role_context :parent => :commentable

  CalendarEvent.acts_as_role_context :parent => :section  if Rails.plugin?(:adva_calendar)
  Photo.acts_as_role_context :parent => :section          if Rails.plugin?(:adva_photos)

  if Rails.plugin?(:adva_forum)
    Board.acts_as_role_context :parent => :section
    Topic.acts_as_role_context :parent => :section
  end
end
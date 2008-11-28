scenario :user_having_several_roles do
  @user = User.new
  @user.save(false)

  @site = stub_site
  @section = stub_section
  @topic = stub_topic
  @comment = stub_comment
  
  @superuser_role      = Rbac::Role.build(:superuser)
  @admin_role          = Rbac::Role.build(:admin, :context => @site)
  @moderator_role      = Rbac::Role.build(:moderator, :context => @section)
  @comment_author_role = Rbac::Role.build(:author, :context => @comment)

  @user.roles << @superuser_role
  @user.roles << @admin_role
  @user.roles << @moderator_role
end

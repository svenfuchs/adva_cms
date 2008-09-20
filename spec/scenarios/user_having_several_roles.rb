scenario :user_having_several_roles do
  @user = User.new
  @user.save(false)

  @site = stub_site
  @section = stub_section
  @topic = stub_topic
  @comment = stub_comment

  @site.stub!(:role_context).and_return @site
  @section.stub!(:role_context).and_return @section
  @comment.stub!(:role_context).and_return @topic

  @superuser_role = Role.build(:superuser)
  @admin_role = Role.build(:admin, @site)
  @moderator_role = Role.build(:moderator, @section)
  @comment_author_role = Role.build(:author, @comment)

  @user.roles << @superuser_role
  @user.roles << @admin_role
  @user.roles << @moderator_role
end
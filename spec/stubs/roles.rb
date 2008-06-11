scenario :roles do
  @site = stub_model Site, :id => 1
  @section = stub_model Section, :id => 1, :site => @site
  
  @admin_role     = Role.build :admin, @site
  @moderator_role = Role.build :moderator, @section
  @superuser_role = Role.build :superuser
  
  @user      = stub_model User, :id => 1, :registered? => true, :roles => []
  @author    = stub_model User, :id => 2, :registered? => true, :roles => []
  @moderator = stub_model User, :id => 1, :registered? => true, :roles => [@moderator_role]
  @admin     = stub_model User, :id => 1, :registered? => true, :roles => [@admin_role]
  @superuser = stub_model User, :id => 1, :registered? => true, :roles => [@superuser_role]

  @content = stub_model Content, :section => @section, :author => @author
  @wikipage = stub_model Wikipage, :section => @section, :author => @author

  @user_role = Role.build :user, @content
  @author_role = Role.build :author, @content
end
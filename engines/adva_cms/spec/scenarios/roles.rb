scenario :roles do
  @site = stub_model Site, :id => 1
  @another_site = stub_model Site, :id => 2

  @section = stub_model Section, :id => 1, :site => @site

  @admin_role     = Rbac::Role.build :admin, :context => @site
  @moderator_role = Rbac::Role.build :moderator, :context => @section
  @superuser_role = Rbac::Role.build :superuser

  @user      = stub_model User, :id => 1, :registered? => true, :roles => []
  @author    = stub_model User, :id => 2, :registered? => true, :roles => []
  @moderator = stub_model User, :id => 1, :registered? => true, :roles => [@moderator_role]
  @admin     = stub_model User, :id => 1, :registered? => true, :roles => [@admin_role]
  @superuser = stub_model User, :id => 1, :registered? => true, :roles => [@superuser_role]

  @content = stub_model Content, :id => 1, :section => @section, :author => @author, :author_id => 1, :author_type => 'User'
  @wikipage = stub_model Wikipage, :section => @section, :author => @author

  @author_role    = Rbac::Role.build :author, :context => @content
  @user_role      = Rbac::Role.build :user #, :context => @content
  @anonymous_role = Rbac::Role.build :anonymous
end

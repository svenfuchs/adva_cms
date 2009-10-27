module Tests
  module HasRole

    define_method "test: a superuser has the global role :superuser" do
      assert_equal true, superuser.has_global_role?(:superuser)
      assert_equal true, superuser.has_global_role?(:superuser, site)
      assert_equal true, superuser.has_global_role?(:superuser, another_site)
    end

    define_method "test: a admin has the global role :admin on 'site'" do
      assert_equal true, site_admin.has_global_role?(:admin, site)
    end

    define_method "test: a moderator for 'site' has the global role :moderator on 'site'" do
      assert_equal true, site_moderator.has_global_role?(:moderator, site)
    end

    define_method "test: a author for 'site' has the global role :author on 'site'" do
      assert_equal true, site_author.has_global_role?(:author, site)
    end

    define_method "test: a designer for 'site' has the global role :designer on 'site'" do
      assert_equal true, site_designer.has_global_role?(:designer, site)
    end

    define_method "test: a admin does not have the global role :admin on 'another site'" do
      assert_equal false, site_admin.has_global_role?(:admin, another_site)
    end

    define_method "test: a moderator for a section (blog) of 'site' does not have the global role :moderator on 'site'" do
      assert_equal false, blog_moderator.has_global_role?(:moderator, site)
    end

    define_method "test: a superuser has permissions for the admin areas of all sites" do
      assert_equal true, superuser.has_permission_for_admin_area?(site)
      assert_equal true, superuser.has_permission_for_admin_area?(another_site)
    end

    define_method "test: a admin, moderator, author and designer for 'site' have permission for the admin area of 'site'" do
      assert_equal true, site_admin.has_permission_for_admin_area?(site)
      assert_equal true, site_moderator.has_permission_for_admin_area?(site)
      assert_equal true, site_author.has_permission_for_admin_area?(site)
      assert_equal true, site_designer.has_permission_for_admin_area?(site)
    end

    define_method "test: a admin, moderator, author and designer for 'site' do not have permissions for the admin area of 'another_site'" do
      assert_equal false, site_admin.has_permission_for_admin_area?(another_site)
      assert_equal false, site_moderator.has_permission_for_admin_area?(another_site)
      assert_equal false, site_author.has_permission_for_admin_area?(another_site)
      assert_equal false, site_designer.has_permission_for_admin_area?(another_site)
    end

    define_method "test: a moderator for a section (blog) of a 'site' does not have permission for the admin area of 'site'" do
      assert_equal false, blog_moderator.has_permission_for_admin_area?(site)
    end

    define_method "test: has_role? (single argument)" do
      assert_equal true, superuser.has_role?(:superuser)
      assert_equal true, superuser.has_role?(:user)
      assert_equal true, superuser.has_role?(:anonymous)
    end

    define_method "test: has_role? (array argument)" do
      assert_equal false, moderator.has_role?([:superuser])
      assert_equal false, moderator.has_role?([:moderator, :superuser])
      assert_equal true,  moderator.has_role?([:moderator, :superuser], blog)
      assert_equal true,  moderator.has_role?([:author, :superuser], content)
    end

    define_method "test: has_explicit_role?" do
      assert_equal true,  superuser.has_explicit_role?(:superuser)
      assert_equal false, superuser.has_explicit_role?(:user)
      assert_equal false, superuser.has_explicit_role?(:anonymous)
    end

    define_method "test: has_permission? raises Rbac::AuthorizingRoleNotFound exception when authorizing role can not be found" do
      assert_raises(Rbac::AuthorizingRoleNotFound) { superuser.has_permission?('drink redbull', Rbac::Context.root) }
    end

    define_method "test: has_permission? returns true when the user has a role that authorizes the action" do
      with_default_permissions(:'edit content' => [:author]) do
        assert_equal true, superuser.has_permission?('edit content', Rbac::Context.root)
      end
    end

    define_method "test: has_permission? returns true for authorized roles that aren't part of the same role hierarchy" do
      with_default_permissions(:'edit content' => [:editor]) do
        content = self.content
        content.section.permissions = { :'edit content' => [:moderator] }
        assert_equal true, moderator.has_permission?('edit content', content)
        assert_equal true, editor.has_permission?('edit content', content)
      end
    end

    protected

    def site
      @site ||= ::Site.find_by_name('a site')
    end

    def another_site
      @another_site ||= ::Site.find_by_name('another site')
    end

    def site_admin
      @site_admin ||= ::User.find_by_name('site admin')
    end

    def blog_moderator
      @blog_moderator ||= ::User.find_by_name('moderator')
    end

    def site_moderator
      @site_moderator ||= ::User.find_by_name('site moderator')
    end

    def site_author
      @site_author ||= ::User.find_by_name('author')
    end

    def site_designer
      @site_designer ||= ::User.find_by_name('designer')
    end

  end
end
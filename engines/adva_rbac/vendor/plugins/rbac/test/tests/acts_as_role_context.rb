module Tests
  module ActsAsRoleContext
    define_method "test: Content acts as a role context" do
      assert_equal true, Content.acts_as_role_context?
    end
  
    define_method "test: there is an Rbac root context" do
      assert_equal true, Rbac::Context.root.is_a?(Rbac::Context::Base)
    end
  
    define_method "test: content can instantiate its role context decorator" do
      assert_equal Content::RoleContext, content.role_context.class
    end
  
    define_method "test: the content's role_context's parent is the blog's role_context" do
      assert_equal blog, content.role_context.parent.object
    end
  
    define_method "test: the section's role_context's parent is the root context" do
      assert_equal Rbac::Context.root, blog.role_context.parent
    end
  
    define_method "test: the blog's role_context includes the content's role_context" do
      assert_equal true, blog.role_context.include?(content.role_context)
    end

    protected
  
      def blog
        @blog ||= ::Section.find_by_title('blog')
      end
    
      def content
        @content ||= Content.find_by_title('content')
      end
  end
end
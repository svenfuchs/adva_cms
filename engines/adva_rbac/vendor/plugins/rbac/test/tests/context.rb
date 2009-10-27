module Tests
  module Context
    define_method "test: authorizing_role_types_for raises when given action is nil" do
      assert_raises(ArgumentError) { content.role_context.authorizing_role_types_for(nil) }
    end
  
    define_method "test: authorizing_role_types_for falls back to permissions from root context" do
      with_default_permissions(:'edit content' => [:author]) do 
        assert_equal [:author], content.role_context.authorizing_role_types_for('edit content')
      end
    end

    define_method "test: authorizing_role_types_for uses object's permissions if given" do
      content = self.content
      content.permissions = { :'edit content' => [:superuser] }
      assert_equal [:superuser], content.role_context.authorizing_role_types_for('edit content')
    end

    define_method "test: expand_roles_for permutate all roles from authorizing_role_types_for w/ all context types" do
      content = self.content
      with_default_permissions(:'edit content' => [:user]) do
        content.permissions = { :'edit content' => [:moderator] }
        expected = %w(author-content-1 author-section-1 editor-content-1 editor-section-1 moderator-content-1 moderator-section-1 superuser user)
        actual = content.role_context.expand_roles_for('edit content')
        assert_equal expected, actual.sort
      end
    end

    protected
  
      def content
        Content.find_by_title('content')
      end
  end
end
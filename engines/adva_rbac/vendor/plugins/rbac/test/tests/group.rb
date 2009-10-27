module Tests
  module Group
    define_method "test: make sure people are members of their groups" do
      assert_equal true, beatles.members.include?(john)
      assert_equal true, beatles.members.include?(paul)

      assert_equal true, stones.members.include?(mick)
      assert_equal true, stones.members.include?(keith)
    end

    define_method "test: make sure people aren't members of groups they don't belong to" do
      assert_equal false, stones.members.include?(john)
      assert_equal false, stones.members.include?(paul)

      assert_equal false, beatles.members.include?(mick)
      assert_equal false, beatles.members.include?(keith)
    end

    define_method "test: people should inherit roles from their groups" do
      assert_equal true, beatles.has_role?(:superuser)
      assert_equal true, john.has_role?(:superuser)
      assert_equal true, paul.has_role?(:superuser)

      assert_equal true, stones.has_role?(:pizzaboy)
      assert_equal true, mick.has_role?(:pizzaboy)
      assert_equal true, keith.has_role?(:pizzaboy)
    end

    define_method "test: people should inherit permissions from their groups" do
      with_default_permissions(:'edit content' => [:editor]) do
        content = self.content
        content.section.permissions = { :'edit content' => [:pizzaboy] }

        assert_equal true, stones.has_permission?('edit content', content)
        assert_equal true, mick.has_permission?('edit content', content)
        assert_equal true, keith.has_permission?('edit content', content)
      end
    end
  end
end
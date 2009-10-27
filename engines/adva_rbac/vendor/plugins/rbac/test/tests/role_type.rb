module Tests
  module RoleType
    define_method "test: RoleType knows all available types" do
      expected = %w(anonymous author editor moderator superuser user)
      actual   = Rbac::RoleType.types.map(&:name).sort
      assert_equal expected, actual & expected
    end
    
    define_method "test: masters" do
      assert_equal [], superuser_type.masters.map(&:name)
      assert_equal ['superuser'], moderator_type.masters.map(&:name)
      assert_equal ['superuser'], editor_type.masters.map(&:name)
      assert_equal ['moderator'], author_type.masters.map(&:name)
      assert_equal ['author', 'editor'], user_type.masters.map(&:name).sort
      assert_equal ['user'], anonymous_type.masters.map(&:name)
    end
    
    define_method "test: all_masters" do
      assert_equal [], superuser_type.all_masters.map(&:name).sort
      assert_equal ['superuser'], moderator_type.all_masters.map(&:name).sort
      assert_equal ['superuser'], editor_type.all_masters.map(&:name)
      assert_equal ['moderator', 'superuser'], author_type.all_masters.map(&:name).sort
      assert_equal ['author', 'editor', 'moderator', 'superuser'], user_type.all_masters.map(&:name).sort
      assert_equal ['author', 'editor', 'moderator', 'superuser', 'user'], anonymous_type.all_masters.map(&:name).sort
    end

    define_method "test: self_and_masters" do
      assert_equal ['superuser'], superuser_type.self_and_masters.map(&:name).sort
      assert_equal ['moderator', 'superuser'], moderator_type.self_and_masters.map(&:name).sort
      assert_equal ['editor', 'superuser'], editor_type.self_and_masters.map(&:name)
      assert_equal ['author', 'moderator', 'superuser'], author_type.self_and_masters.map(&:name).sort
      assert_equal ['author', 'editor', 'moderator', 'superuser', 'user'], user_type.self_and_masters.map(&:name).sort
      assert_equal ['anonymous', 'author', 'editor', 'moderator', 'superuser', 'user'], anonymous_type.self_and_masters.map(&:name).sort
    end

    define_method "test: minions" do
      assert_equal ['editor', 'moderator'], superuser_type.minions.map(&:name).sort
      assert_equal ['author'], moderator_type.minions.map(&:name).sort
      assert_equal ['user'], author_type.minions.map(&:name).sort
      assert_equal ['user'], editor_type.minions.map(&:name).sort
      assert_equal ['anonymous'], user_type.minions.map(&:name).sort
      assert_equal [], anonymous_type.minions.map(&:name).sort
    end

    define_method "test: all_minions" do
      assert_equal ['anonymous', 'author', 'editor', 'moderator', 'user'], superuser_type.all_minions.map(&:name).sort
      assert_equal ['anonymous', 'author', 'user'], moderator_type.all_minions.map(&:name).sort
      assert_equal ['anonymous', 'user'], author_type.all_minions.map(&:name).sort
      assert_equal ['anonymous', 'user'], editor_type.all_minions.map(&:name).sort
      assert_equal ['anonymous'], user_type.all_minions.map(&:name).sort
      assert_equal [], anonymous_type.all_minions.map(&:name).sort
    end

    define_method "test: self_and_minions" do
      assert_equal ['anonymous', 'author', 'editor', 'moderator', 'superuser', 'user'], superuser_type.self_and_minions.map(&:name).sort
      assert_equal ['anonymous', 'author', 'moderator', 'user'], moderator_type.self_and_minions.map(&:name).sort
      assert_equal ['anonymous', 'author', 'user'], author_type.self_and_minions.map(&:name).sort
      assert_equal ['anonymous', 'editor', 'user'], editor_type.self_and_minions.map(&:name).sort
      assert_equal ['anonymous', 'user'], user_type.self_and_minions.map(&:name).sort
      assert_equal ['anonymous'], anonymous_type.self_and_minions.map(&:name).sort
    end

    define_method "test: RoleType#build returns an Rbac::RoleType" do
      %w(anonymous author editor moderator superuser user).each do |role_type|
        assert Rbac::RoleType.build(role_type.to_sym).respond_to?(:granted_to?)
      end
    end

    define_method "test: RoleType#granted_to? returns true for assigned role and all minion roles" do
      assert_equal true,  superuser_type.granted_to?(superuser)
      assert_equal true,  moderator_type.granted_to?(superuser)
      assert_equal true,  editor_type.granted_to?(superuser)
      assert_equal true,  author_type.granted_to?(superuser, content)
      assert_equal true,  user_type.granted_to?(superuser)
      assert_equal true,  anonymous_type.granted_to?(superuser)
    
      assert_equal false, superuser_type.granted_to?(moderator)
      assert_equal false, editor_type.granted_to?(moderator)
      assert_equal false, moderator_type.granted_to?(moderator)
      assert_equal true,  moderator_type.granted_to?(moderator, blog)
      assert_equal true,  author_type.granted_to?(moderator, content)
      assert_equal true,  user_type.granted_to?(moderator)
      assert_equal true,  anonymous_type.granted_to?(moderator )
    
      assert_equal false, superuser_type.granted_to?(author)
      assert_equal false, editor_type.granted_to?(author)
      assert_equal false, moderator_type.granted_to?(author)
      assert_equal false, moderator_type.granted_to?(author, content)
      assert_equal true,  author_type.granted_to?(author, content)
      assert_equal true,  user_type.granted_to?(author)
      assert_equal true,  anonymous_type.granted_to?(author)
    
      assert_equal false, superuser_type.granted_to?(user)
      assert_equal false, editor_type.granted_to?(user)
      assert_equal false, moderator_type.granted_to?(user)
      assert_equal false, moderator_type.granted_to?(user, content)
      assert_equal false, author_type.granted_to?(user, content)
      assert_equal true,  user_type.granted_to?(user)
      assert_equal true,  anonymous_type.granted_to?(user)
    
      assert_equal false, superuser_type.granted_to?(anonymous)
      assert_equal false, editor_type.granted_to?(anonymous)
      assert_equal false, moderator_type.granted_to?(anonymous)
      assert_equal false, moderator_type.granted_to?(anonymous, content)
      assert_equal false, author_type.granted_to?(anonymous, content)
      assert_equal false, user_type.granted_to?(anonymous)
      assert_equal true,  anonymous_type.granted_to?(anonymous)
    end
  end
end

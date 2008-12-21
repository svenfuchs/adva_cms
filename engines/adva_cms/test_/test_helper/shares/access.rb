class Test::Unit::TestCase
  share :access_granted do
    before do
      stub(@controller).require_authentication
      stub(@controller).guard_permission
    end
  end
  
  [:site, :section, :article, :wikipage, :category, :cached_page, :theme, :theme_file].each do |type|
    [:show, :create, :update, :destroy, :manage].each do |action|
      share :"superuser_may_#{action}_#{type}" do
        before { Rbac::Context.permissions[:"#{action} #{type}"] = 'superuser' }
      end

      share :"admin_may_#{action}_#{type}" do
        before { Rbac::Context.permissions[:"#{action} #{type}"] = 'admin' }
      end

      share :"moderator_may_#{action}_#{type}" do
        before { Rbac::Context.permissions[:"#{action} #{type}"] = 'moderator' }
      end
    end
  end
end
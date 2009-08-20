require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

# With.aspects << :access_control

class AdminPluginsControllerTest < ActionController::TestCase
  tests Admin::PluginsController

  with_common :is_superuser, :a_site, :a_plugin

  def default_params
    { :site_id => @site.id }
  end

  test "is an Admin::BaseController" do
    @controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/', :site_id => "1" do |r|
      r.it_maps :get,    "plugins",             :action => 'index'
      r.it_maps :get,    "plugins/test_plugin", :action => 'show',    :id => 'test_plugin'
      r.it_maps :put,    "plugins/test_plugin", :action => 'update',  :id => 'test_plugin'
      r.it_maps :delete, "plugins/test_plugin", :action => 'destroy', :id => 'test_plugin'
    end
  end

  describe "GET to :index" do
    action { get :index, default_params }

    it_guards_permissions :manage, :site

    with :access_granted do
      it_assigns :plugins
      it_renders :template, :index do
        has_tag 'table[id=plugins]'
      end
    end
  end

  describe "GET to :show" do
    action { get :show, default_params.merge(:id => @plugin.id) }

    it_guards_permissions :manage, :site

    with :access_granted do
      it_assigns :plugin
      it_renders :template, :show do
        has_tag 'input[name=?][value=?]', 'plugin[string]', 'default string'
        has_tag 'textarea[name=?]', 'plugin[text]', 'default text'

        has_text @plugin.about['description']
        has_tag 'div[id=sidebar]' do
          has_text @plugin.about['author']
          has_text @plugin.about['homepage']
          has_text @plugin.about['summary']
        end
      end
    end
  end

  # describe "PUT to :update" do
  #   action { put :update, default_params.merge(@params) }
  #   before { @params = { :id => @plugin.id, :string => 'changed' } }
  #
  #   it_guards_permissions :manage, :site
  #
  #   with :access_granted do
  #     it_assigns :plugin
  #     it_redirects_to { @member_path }
  #     it_assigns_flash_cookie :notice => :not_nil
  #
  #     it "updates the plugin's config options" do
  #       @plugin.send(:config).reload.options[:string].should =~ /changed/
  #     end
  #   end
  # end
  #
  # describe "DELETE to :destroy" do
  #   action { delete :destroy, default_params.merge(:id => @plugin.id)}
  #
  #   it_guards_permissions :manage, :site
  #
  #   with :access_granted do
  #     it_assigns :plugin
  #     it_redirects_to { @member_path }
  #     it_assigns_flash_cookie :notice => :not_nil
  #
  #     it "resets the plugin's config options" do
  #       @plugin.send(:config).reload.options.should == {}
  #     end
  #   end
  # end
end

require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class CustomTemplatesTestController < ActionController::Base
  layout 'default'
  prepend_view_path File.expand_path(File.dirname(__FILE__) + '/../../../fixtures/templates')
end

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id', :controller => 'custom_templates_test'
end

class CustomTemplatesTest < ActionController::TestCase
  tests CustomTemplatesTestController
  
  test "render_options with template/layout given as a string" do
    section = Section.new :options => { :template => 'foo', :layout => 'bar' }
    section.render_options(:show).should == { :template => 'foo/show', :layout => 'layouts/bar'}
  end
  
  test "render_options with template/layout given as a hash" do
    section = Section.new :options => { :template => { :show => 'foo/show' }, :layout => { :show => 'layouts/bar' } }
    section.render_options(:show).should == { :template => 'foo/show', :layout => 'layouts/bar'}
  end
  
  test "render_options with template/layout given as a string (shortcut)" do
    section = Section.new :options => { :template => 'foo', :layout => 'bar' }
    section.render_options(:show).should == { :template => 'foo/show', :layout => 'layouts/bar'}
  end
  
  test "render_options with template/layout given as a hash (shortcut)" do
    section = Section.new :options => { :template => { :show => 'foo' }, :layout => { :show => 'bar' } }
    section.render_options(:show).should == { :template => 'foo/show', :layout => 'layouts/bar'}
  end

  test "custom template exists, so it renders the custom template" do
    section = Section.new :options => { :template => 'alternative_templates' }
    @controller.instance_variable_set :@section, section
    get :index
    assert_template 'alternative_templates/index'
  end

  test "custom template does not exist, so it renders the default" do
    section = Section.new :options => { :template => 'alternative_templates' }
    @controller.instance_variable_set :@section, section
    get :show
    assert_template 'custom_templates_test/show'
  end

  test "custom layout exists, so it renders the custom layout" do
    section = Section.new :options => { :layout => 'alternative' }
    @controller.instance_variable_set :@section, section
    get :index
    @response.layout.should == 'layouts/alternative'
  end

  test "custom layout does not exist, so it renders the default" do
    section = Section.new :options => { :layout => 'does not exist' }
    @controller.instance_variable_set :@section, section
    get :show
    assert_template 'custom_templates_test/show'
    @response.layout.should == 'layouts/default'
  end
end

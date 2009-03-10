require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

if ActionController::Base.respond_to?(:renders_in_context)
  class ContextTemplatesTestController < ActionController::Base
    layout 'default'
    renders_in_context :current_resource
    prepend_view_path File.expand_path(File.dirname(__FILE__) + '/../../fixtures/templates')
  
    def current_resource
      @section
    end
  end

  ActionController::Routing::Routes.draw do |map|
    map.connect 'context_templates_test/:action/:id', :controller => 'context_templates_test'
  end

  class RenderWithContextTemplatesTest < ActionController::TestCase
    tests ContextTemplatesTestController
  
    def setup
      super
      @section = Section.new
      @options = { :action => 'foo' }
      @controller.params[:format] = nil
    end
  
    # template_options return the expected values
  
    test "template_options with template given as a full template name" do
      section = Section.new :options => { :template => 'foo/show' }
      section.template_options(:show).should == { :template => 'foo/show' }
    end
  
    test "template_options with template given as a full template name (including the templates/ subdir)" do
      section = Section.new :options => { :template => 'templates/foo/show' }
      section.template_options(:show).should == { :template => 'foo/show' }
    end
  
    test "template_options with template given as a wildcard template inserts the current action" do
      section = Section.new :options => { :template => 'foo/*' }
      section.template_options(:show).should == { :template => 'foo/show' }
    end
  
    test "template_options with template given as a wildcard template inserts the current action (including the templates/ subdir)" do
      section = Section.new :options => { :template => 'templates/foo/*' }
      section.template_options(:show).should == { :template => 'foo/show' }
    end
  
    test "template_options with layout given as template name" do
      section = Section.new :options => { :layout => 'bar' }
      section.template_options(:show).should == { :layout => 'layouts/bar' }
    end
  
    test "template_options with layout given as template name (including the layouts/ subdir)" do
      section = Section.new :options => { :layout => 'layouts/bar' }
      section.template_options(:show).should == { :layout => 'layouts/bar' }
    end
  
    # context_render?
  
    test "context_render? returns true for a restricted set of conditions" do
      @controller.send(:context_render?, @options).should be_true
    end
  
    test "context_render? returns false in the admin namespace" do
      @controller.request.path = '/admin/foo'
      @controller.send(:context_render?, @options).should be_false
    end
  
    test "context_render? returns false when the format is not html" do
      @controller.params[:format] = 'js'
      @controller.send(:context_render?, @options).should be_false
    end
  
    test "context_render? returns false when options is not a Hash" do
      @controller.send(:context_render?, :foo).should be_false
    end
  
    test "context_render? returns false when the options hash does not contain any of the keys :template and :action" do
      @controller.send(:context_render?, { :layout => 'foo' }).should be_false
    end

    # actually picks the correct template
  
    test "context template exists, so it renders the context template" do
      section = Section.new :options => { :template => 'alternative_templates/*' }
      @controller.instance_variable_set :@section, section
      get :index
      assert_template 'alternative_templates/index'
    end
  
    test "context template does not exist, so it renders the default template" do
      section = Section.new :options => { :template => 'does_not_exist/*' }
      @controller.instance_variable_set :@section, section
      get :index
      assert_template 'context_templates_test/index'
    end
  
    test "context layout exists, so it renders the context layout" do
      section = Section.new :options => { :layout => 'alternative' }
      @controller.instance_variable_set :@section, section
      get :index
      @response.layout.should == 'layouts/alternative'
    end
  
    test "context layout does not exist, so it renders the default layout" do
      section = Section.new :options => { :layout => 'does not exist' }
      @controller.instance_variable_set :@section, section
      get :index
      @response.layout.should == 'layouts/default'
    end
  
    test "context layout and template exist, so it renders both" do
      section = Section.new :options => { :template => 'alternative_templates/*', :layout => 'alternative' }
      @controller.instance_variable_set :@section, section
      get :index
      assert_template 'alternative_templates/index'
      @response.layout.should == 'layouts/alternative'
    end
  
    test "context template exists but layout doesn't, so it still renders the template" do
      section = Section.new :options => { :template => 'alternative_templates/*', :layout => 'does not exist' }
      @controller.instance_variable_set :@section, section
      get :index
      assert_template 'alternative_templates/index'
      @response.layout.should == 'layouts/default'
    end
  
    test "context layout exists but template doesn't, so it still renders the layout" do
      section = Section.new :options => { :template => 'does_not_exist/*', :layout => 'alternative' }
      @controller.instance_variable_set :@section, section
      get :index
      assert_template 'context_templates_test/index'
      @response.layout.should == 'layouts/alternative'
    end
  end
end
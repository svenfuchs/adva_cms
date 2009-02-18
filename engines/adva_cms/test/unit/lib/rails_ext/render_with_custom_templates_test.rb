require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class CustomTemplatesTest < ActionController::TestCase
  class TestController < ActionController::Base
    layout 'default'
    prepend_view_path File.expand_path(File.dirname(__FILE__) + '/../../../fixtures/templates')
  end

  tests TestController
  
  def setup
    super
    @options = { :action => 'foo' }
    @controller.params[:format] = nil
    @controller.instance_variable_set :@section, Section.new
  end
  
  # render_options return the expected values

  test "render_options with template given as a full template name" do
    section = Section.new :options => { :template => 'foo/show' }
    section.render_options(:show).should == { :template => 'foo/show' }
  end
  
  test "render_options with template given as a full template name (including the templates/ subdir)" do
    section = Section.new :options => { :template => 'templates/foo/show' }
    section.render_options(:show).should == { :template => 'foo/show' }
  end
  
  test "render_options with template given as a wildcard template inserts the current action" do
    section = Section.new :options => { :template => 'foo/*' }
    section.render_options(:show).should == { :template => 'foo/show' }
  end
  
  test "render_options with template given as a wildcard template inserts the current action (including the templates/ subdir)" do
    section = Section.new :options => { :template => 'templates/foo/*' }
    section.render_options(:show).should == { :template => 'foo/show' }
  end
  
  test "render_options with layout given as template name" do
    section = Section.new :options => { :layout => 'bar' }
    section.render_options(:show).should == { :layout => 'layouts/bar' }
  end
  
  test "render_options with layout given as template name (including the layouts/ subdir)" do
    section = Section.new :options => { :layout => 'layouts/bar' }
    section.render_options(:show).should == { :layout => 'layouts/bar' }
  end
  
  # custom_render?
  
  test "custom_render? returns true for a restricted set of conditions" do
    @controller.send(:custom_render?, @options).should be_true
  end
  
  test "custom_render? returns false in the admin namespace" do
    @controller.request.path = '/admin/foo'
    @controller.send(:custom_render?, @options).should be_false
  end
  
  test "custom_render? returns false when no section is present" do
    @controller.instance_variable_set :@section, nil
    @controller.send(:custom_render?, @options).should be_false
  end
  
  test "custom_render? returns false when the format is not html" do
    @controller.params[:format] = 'js'
    @controller.send(:custom_render?, @options).should be_false
  end
  
  test "custom_render? returns false when options is not a Hash" do
    @controller.send(:custom_render?, []).should be_false
  end
  
  test "custom_render? returns false when the options hash does not contain any of the keys :template and :action" do
    @controller.send(:custom_render?, { :layout => 'foo' }).should be_false
  end

  # actually picks the correct template
  
  test "custom template exists, so it renders the custom template" do
    section = Section.new :options => { :template => 'alternative_templates/*' }
    @controller.instance_variable_set :@section, section
    get :index
    assert_template 'alternative_templates/index'
  end
  
  test "custom template does not exist, so it renders the default" do
    section = Section.new :options => { :template => 'alternative_templates/*' }
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

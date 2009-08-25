require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ThemesHelperTest < ThemeViewTestCase
  include ThemeTestHelper
  # include ThemesHelper
  include AssetTagHelper
  
  def setup
    super

    @theme = Theme.find_by_theme_id 'a-theme'
    @site = @theme.site
    @controller = TestController.new
    @request = ActionController::TestRequest.new
    
    @controller.instance_variable_set(:@site, @site)
    (class << @controller; self; end).send :attr_accessor, :site

    uploaded_javascript
    uploaded_stylesheet
    assert ActionController::Base.perform_caching, 'assuming that perform_caching is turned on'
  end

  # FIXME why don't any of these include timestamps?

  test 'theme_image_tag' do
    tag = theme_image_tag('a-theme', 'rails.png')
    tag.should == "<img alt=\"Rails\" src=\"/sites/site-#{@site.id}/themes/a-theme/images/rails.png\" />"
  end

  test 'theme_javascript_include_tag' do
    tag = theme_javascript_include_tag('a-theme', 'foo')
    tag.should == "<script src=\"/sites/site-#{@site.id}/themes/a-theme/javascripts/foo.js\" type=\"text/javascript\"></script>"
  end

  test 'theme_javascript_include_tag with :all' do
    tag = theme_javascript_include_tag('a-theme', :all)
    tag.should == "<script src=\"/sites/site-#{@site.id}/themes/a-theme/javascripts/effects.js\" type=\"text/javascript\"></script>"
  end
  
  test 'theme_javascript_include_tag with caching' do
    tag = theme_javascript_include_tag('a-theme', 'effects', :cache => true)
    tag.should == "<script src=\"/sites/site-#{@site.id}/themes/a-theme/javascripts/all.js\" type=\"text/javascript\"></script>"
    "#{@theme.path}/javascripts/all.js".should be_file
  end

  test 'theme_stylesheet_link_tag' do
    tag = theme_stylesheet_link_tag('a-theme', 'foo')
    tag.should == "<link href=\"/sites/site-#{@site.id}/themes/a-theme/stylesheets/foo.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />"
  end

  test 'theme_stylesheet_link_tag with :all' do
    tag = theme_stylesheet_link_tag('a-theme', :all)
    tag.should == "<link href=\"/sites/site-#{@site.id}/themes/a-theme/stylesheets/styles.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />"
  end
  
  test 'theme_stylesheet_link_tag with caching' do
    tag = theme_stylesheet_link_tag('a-theme', 'styles', :cache => true)
    tag.should == "<link href=\"/sites/site-#{@site.id}/themes/a-theme/stylesheets/all.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />"
    "#{@theme.path}/stylesheets/all.css".should be_file
  end
end
  
require File.dirname(__FILE__) + '/../../spec_helper'

describe "Admin::Themes:" do
  include SpecViewHelper
  
  before :each do
    scenario :site, :theme, :theme_file
    assigns[:site] = @site
    
    @admin_themes_path = '/admin/sites/1/themes'
    @admin_theme_path = '/admin/sites/1/themes/theme-1'
    @new_admin_theme_path = '/admin/sites/1/themes/new'
    
    template.stub!(:admin_themes_path).and_return @admin_themes_path
    template.stub!(:admin_theme_path).and_return @admin_theme_path
    template.stub!(:new_admin_theme_path).and_return @new_admin_theme_path
  end
  
  describe "the :index view" do
    before :each do 
      assigns[:themes] = @themes
      @theme.stub!(:preview).and_return mock('preview', :path => '/path/to/preview')
    end
    
    it "displays a link to the :new action" do 
      render "admin/themes/index"
      response.should have_tag('a[href=?]', @new_admin_theme_path)
    end
    
    it "displays a list of themes" do 
      render "admin/themes/index"
      response.should have_tag('ul[id=?]', 'themelist')
    end
  end

  describe "the :show view" do
    before :each do 
      assigns[:theme] = @theme
      template.stub_render hash_including(:partial => 'form')
    end
    
    it "displays a form to edit the theme" do 
      render "admin/themes/show"
      response.should have_tag('form[action=?]', @admin_theme_path) do |form|
        form.should have_tag('input[name=?][value=?]', '_method', 'put')
      end
    end
    
    it "renders the form partial" do 
      template.expect_render hash_including(:partial => 'form')
      render "admin/themes/show"
    end
  end  

  describe "the :new view" do
    before :each do 
      assigns[:theme] = @theme
      template.stub_render hash_including(:partial => 'form')
    end
    
    it "displays a form to add a new theme" do 
      render "admin/themes/new"
      response.should have_tag('form[action=?][method=?]', @admin_themes_path, :post)
    end
    
    it "renders the form partial" do 
      template.expect_render hash_including(:partial => 'form')
      render "admin/themes/new"
    end
  end  

  describe "the form partial" do
    before :each do 
      template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:theme, @theme, template, {}, nil)
    end

    it "renders theme settings fields" do
      render "admin/themes/_form"
      response.should have_tag('input[name=?]', 'theme[name]')
    end
  end  
end
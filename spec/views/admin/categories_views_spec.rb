require File.dirname(__FILE__) + '/../../spec_helper'

describe "Admin::Categories:" do
  include SpecViewHelper
  
  before :each do
    scenario :site, :section, :category
    
    assigns[:section] = @section
    assigns[:site] = @site

    set_resource_paths :category, '/admin/sites/1/sections/1/'
    
    template.stub!(:admin_categories_path).and_return(@collection_path)
    template.stub!(:admin_category_path).and_return(@member_path)
    template.stub!(:new_admin_category_path).and_return @new_member_path
    template.stub!(:edit_admin_category_path).and_return(@edit_member_path)
    template.stub!(:update_all_admin_categories_path).and_return("#{@collection_path}/update_all")
    
    template.stub!(:link_to_function)
    template.stub!(:image_tag)
    template.stub!(:remote_function)
    template.stub!(:form_for)

    template.stub_render hash_including(:partial => 'category')
  end
  
  describe "the :index view" do
    before :each do
      assigns[:categories] = @categories
    end
    
    it "should display a list of categories" do
      render "admin/categories/index"
      response.should have_tag('ul[id=?]', 'categories')
    end
    
    it "should render the category partial with the categories collection" do
      template.stub_render hash_including(:partial => 'category', :collection => @categories)
      render "admin/categories/index"
    end   
    
    it "should render a link to make the categories list sortable depending on the categories count" do      
      @section.categories.should_receive(:size).and_return 5    
      render "admin/categories/index"
    end
    
    it "should render a link to make the categories list sortable when categories count is > 2" do      
      @section.categories.stub!(:size).and_return 3  
      template.should_receive(:link_to_function).with('Reorder categories', anything(), anything())
      render "admin/categories/index"
    end
  end
    
  describe "the :new view" do
    before :each do
      assigns[:category] = @category
    end
    
    it "should render a form for adding a new category" do
      Category.stub!(:new).and_return @category
      template.should_receive(:form_for).with(:category, @category, :url => @collection_path)
      render "admin/categories/new"
    end
  end
  
  describe "the :edit view" do
    before :each do
      assigns[:category] = @category
    end
    
    it "should render a form for editing the category" do
      template.should_receive(:form_for).with(:category, @category, hash_including(:url => @member_path))
      render "admin/categories/edit"      
    end
  end
  
  describe "the category partial" do
    before :each do 
      template.stub!(:object).and_return(@category)
    end
    
    it "should render a link to the category edit view" do      
      render "admin/categories/_category"
      response.should have_tag('a[href=?]', @edit_member_path)
    end
    
    it "should render itself for nested categories" do
      template.expect_render hash_including(:partial => 'category')
      render "admin/categories/_category"
    end
  end
end
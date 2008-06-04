require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "Category page_caching" do
  include SpecControllerHelper
  
  describe Admin::CategoriesController do
    
    it "should activate the CategorySweeper" do
      Admin::CategoriesController.should_receive(:cache_sweeper) do |*args|
        args.should include(:category_sweeper)
      end
      load 'admin/categories_controller.rb'
    end

    it "should have the CategorySweeper observe Category create, update and destroy events" do
      Admin::CategoriesController.should_receive(:cache_sweeper) do |*args|
        options = args.extract_options!
        options[:only].should == [:create, :update, :destroy]
      end
      load 'admin/categories_controller.rb'
    end
  end
  
  describe "CategorySweeper" do
    controller_name 'admin/categories'

    before :each do
      scenario :blog, :category
      @category.stub!(:section).and_return @blog
      @sweeper = CategorySweeper.instance
    end
    
    it "should expire pages that reference an category when an category was saved" do
      @sweeper.should_receive(:expire_cached_pages_by_section).with(@blog)
      @sweeper.after_save(@category)
    end
  end
end
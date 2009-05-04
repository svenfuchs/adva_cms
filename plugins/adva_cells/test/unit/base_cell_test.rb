require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class BaseCellTest < ActiveSupport::TestCase
  def setup
    super
    @site       = Site.first
    @section    = @site.sections.last
    @root       = @site.sections.root
    @controller = CellTestController.new
    @cell       = BaseCell.new(@controller)
    @cell.send(:set_site)
  end
  
  # .set_site
  test "#set_site sets the site from the controller" do
    @cell.instance_variable_get(:@site).should == @controller.site
  end
  
  # .set_section
  test "#set_section sets the section from options[:section] if available" do
    @cell.instance_variable_set(:@opts, {:section => @section.id})
    @cell.send(:set_section)
    @cell.instance_variable_get(:@section).should == @section
  end

  test "#set_section defaults the section to controller.section" do
    @cell.send(:set_section)
    @cell.instance_variable_get(:@section).should == @controller.section
  end

  test "#set_section defaults the section to the site's root section if controller.section is not set" do
    stub(@controller).section.returns(nil)
    @cell.send(:set_section)
    @cell.instance_variable_get(:@section).should == @root
  end
  
  # .boolean_option
  test "#boolean_option typecasts a string 'true' to true" do
    @cell.instance_variable_set(:@opts, {:foo => 'true'})
    @cell.send(:boolean_option, :foo).should == true
  end

  test "#boolean_option typecasts a string 'false' to false" do
    @cell.instance_variable_set(:@opts, {:foo => 'false'})
    @cell.send(:boolean_option, :foo).should == false
  end

  test "#boolean_option typecasts a string '1' to true" do
    @cell.instance_variable_set(:@opts, {:foo => '1'})
    @cell.send(:boolean_option, :foo).should == true
  end

  test "#boolean_option typecasts a string '0' to false" do
    @cell.instance_variable_set(:@opts, {:foo => '0'})
    @cell.send(:boolean_option, :foo).should == false
  end

  # .include_child_sections?
  test "#include_child_sections is true when the option :include_child_sections typecasts to true" do
    @cell.instance_variable_set(:@opts, {:include_child_sections => 'true'})
    @cell.send(:include_child_sections?).should == true
  end
  
  # FIXME can not test expectations on Article class methods with RR's mock library?
  #
  # .with_sections_scope
  # test "#with_sections_scope scopes ActiveRecord::Base.find to the current section
  #                            when include_child_sections? is false" do
  #   @cell.send(:set_section)
  #   scope = hash_including(:find => { :conditions => { :section_id => @section.id}, :include => 'section' })
  #   mock(Article).scope(scope)
  #   @cell.send(Article, :with_sections_scope) { Article.all }
  # end
  # 
  # test "#with_sections_scope scopes ActiveRecord::Base.find to the current section and all child sections
  #     when include_child_sections? is true" do
  #   @cell.instance_variable_set(:@opts, {:include_child_sections => 'true'})
  #   @cell.send(:set_section)
  #   scope = hash_including(:find => { :conditions => { :section_id => @section.id }, :include => 'section' })
  #   mock(Article).scope(scope)
  #   @cell.send(Article, :with_sections_scope) { Article.all }
  # end
end
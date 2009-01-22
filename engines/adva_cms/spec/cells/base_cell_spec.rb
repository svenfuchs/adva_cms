require File.dirname(__FILE__) + '/../spec_helper'

describe BaseCell do
  before :each do
    @site = Site.first || Site.create!(:name => 'name', :host => 'test.host')
    @section = @site.sections.first || Section.create!(:site => @site, :title => 'title')

    request = mock('request', :path => '/path/of/request')
    @controller = mock('controller', :site => @site, :section => @section)
    @cell = BaseCell.new(@controller, nil)
    @cell.send(:set_site)
  end
  
  # set_site
  it "#set_site sets the site from the controller" do
    @cell.instance_variable_get(:@site).should == @controller.site
  end
  
  # set_section
  it "#set_section sets the section from options[:section_id] if available" do
    @cell.instance_variable_set(:@opts, {:section_id => @section.id})
    @cell.send(:set_section)
    @cell.instance_variable_get(:@section).should == @section
  end
  
  it "#set_section defaults the section to controller.section first" do
    @cell.send(:set_section)
    @cell.instance_variable_get(:@section).should == @section
  end
  
  it "#set_section defaults the section to the site's root section second" do
    @controller.stub!(:section).and_return(nil)
    @site.sections.should_receive(:root).and_return :section
    @cell.send(:set_section)
    @cell.instance_variable_get(:@section).should == :section
  end
  
  # boolean_option
  it "#boolean_option typecasts a string 'true' to true" do
    @cell.instance_variable_set(:@opts, {:foo => 'true'})
    @cell.send(:boolean_option, :foo).should == true
  end
  
  it "#boolean_option typecasts a string 'false' to false" do
    @cell.instance_variable_set(:@opts, {:foo => 'false'})
    @cell.send(:boolean_option, :foo).should == false
  end
  
  it "#boolean_option typecasts a string '1' to true" do
    @cell.instance_variable_set(:@opts, {:foo => '1'})
    @cell.send(:boolean_option, :foo).should == true
  end
  
  it "#boolean_option typecasts a string '0' to false" do
    @cell.instance_variable_set(:@opts, {:foo => '0'})
    @cell.send(:boolean_option, :foo).should == false
  end
  
  # include_child_sections?
  it "#include_child_sections is true when the option :include_child_sections typecasts to true" do
    @cell.instance_variable_set(:@opts, {:include_child_sections => 'true'})
    @cell.send(:include_child_sections?).should == true
  end

  # FIXME can not spec expectations on Article class methods with RSpec's mock library?

  # # with_sections_scope
  # it "#with_sections_scope scopes ActiveRecord::Base.find to the current section
  #     when include_child_sections? is false" do
  #   @cell.send(:set_section)
  #   scope = hash_including(:find => { :conditions => { :section_id => @section.id}, :include => 'section' })
  #   Article.should_receive(:with_scope).with scope
  #   @cell.send(Article, :with_sections_scope) { Article.all }
  # end
  # 
  # it "#with_sections_scope scopes ActiveRecord::Base.find to the current section and all child sections 
  #     when include_child_sections? is true" do
  #   @cell.instance_variable_set(:@opts, {:include_child_sections => 'true'})
  #   @cell.send(:set_section)
  #   scope = hash_including(:find => { :conditions => { :section_id => @section.id }, :include => 'section' })
  #   Article.should_receive(:with_scope).with scope
  #   @cell.send(Article, :with_sections_scope) { Article.all }
  # end
end
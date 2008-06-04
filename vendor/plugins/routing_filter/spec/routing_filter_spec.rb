require File.dirname(__FILE__) + '/spec_helper.rb'

Routing = ActionController::Routing

describe 'RoutingFilter' do
  before :each do
    @controller = instantiate_controller :locale => 'de', :section_id => 1
  end
  
  def draw_routes(&block)
    set = returning Routing::RouteSet.new do |set|
      class << set; def clear!; end; end
      set.draw &block 
      silence_warnings{ Routing.const_set 'Routes', set }
    end
    set
  end
  
  def instantiate_controller(params)
    returning ActionController::Base.new do |controller|
      request = ActionController::TestRequest.new
      url = ActionController::UrlRewriter.new(request, params)
      controller.stub!(:request).and_return request
      controller.instance_variable_set :@url, url 
      controller
    end
  end
  
  describe 'basics' do
    before :each do
      @set = draw_routes do |map|
        map.section 'sections/:section_id', :controller => 'sections', :action => "show"
        map.filter 'locale'
        map.filter 'root_section'
      end
  
      @locale_filter = @set.filters.first
      @root_section_filter = @set.filters.last          
    end
    
    it 'installs a filter to the route set' do
      @locale_filter.should be_instance_of(RoutingFilter::Locale)
    end
  
    it 'calls the first filter for route recognition' do
      @locale_filter.should_receive(:around_recognition).and_return {}
      @set.recognize_path '/de/sections/1', {}
    end
  
    it 'calls the second filter for route recognition' do
      @root_section_filter.should_receive(:around_recognition).and_return {}
      @set.recognize_path '/de/sections/1', {}
    end
  
    it 'calls the filter for url_for' do
      @locale_filter.should_receive :after_generate
      @controller.send :url_for, :controller => 'sections', :action => 'show', :section_id => 1
    end
  
    it 'calls the filter for named route url_helper' do
      @locale_filter.should_receive :after_generate
      @controller.send :section_path, :section_id => 1
    end      
    
    it 'calls the filter for named route url_helper with "optimized" generation blocks' do
      @locale_filter.should_receive :after_generate
      @controller.send :section_path, 1
    end
  
    it 'calls the filter for named route polymorphic_path' do
      @locale_filter.should_receive :after_generate
      @controller.send :section_path, Section.new
    end
  end
  
  describe 'the locale filter' do
    before :each do
      @set = draw_routes do |map|
        map.section 'sections/:section_id', :controller => 'sections', :action => "show"
        map.filter 'locale'
      end
          
      @locale_filter = @set.filters.first
      @root_section_filter = @set.filters.last          
    end
    
    it 'recognizes the path /de/sections/1 and sets the :locale param' do
      @set.recognize_path('/de/sections/1', {})[:locale].should == 'de'
    end
    
    it 'recognizes the path /sections/1 and does not set a :locale param' do
      @set.recognize_path('/sections/1', {})[:locale].should be_nil
    end
    
    it 'with the default locale set does not change a generated path' do
      @controller.instance_variable_set :@locale, 'en'
      @controller.send(:section_path, :section_id => 1).should == '/sections/1'
    end
    
    it 'with a non-default locale appends it to the generated path' do
      @controller.instance_variable_set :@locale, 'de'
      @controller.send(:section_path, :section_id => 1).should == '/de/sections/1'
    end
    
    it 'with no locale present does not change a generated path' do
      @controller.instance_variable_set :@locale, nil
      @controller.send(:section_path, :section_id => 1).should == '/sections/1'
    end
  end
end



























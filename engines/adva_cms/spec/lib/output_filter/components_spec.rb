require File.dirname(__FILE__) + '/../../spec_helper'

describe OutputFilter::Components do
  before :each do
    @filter = OutputFilter::Components.new

    @html = <<-html
      <html>
        <body>
          <component name="blog/best_articles" section_id="1" count="10" />
          <component name="blog/recent_articles" section_id="1" count="5" />
          something>invalid
        </body>
      </html>
    html

    @components = { '<component name="blog/best_articles" section_id="1" count="10" />'  => 
                      ['blog/best_articles', {'section_id' => '1', 'count' => '10'}],
                    '<component name="blog/recent_articles" section_id="1" count="5" />' => 
                      ['blog/recent_articles', {'section_id' => '1', 'count' => '5'}] }
  end
  
  describe '#after' do
    before :each do
      response    = mock 'response', :body => @html, :template => mock('template', :component => 'component rendered')
      @controller = mock 'controller', :response => response
    end
    
    it "renders the components" do
      @components.each do |tag, component|
        @controller.response.template.should_receive(:component).with(*component)
      end
      @filter.after(@controller)
    end
    
    it "replaces the component tags with rendering results" do
      @filter.after(@controller)
      @controller.response.body.scan(/component rendered/).should have(2).things
    end
  end
  
  describe 'SimpleParser' do
    before :each do
      @parser = OutputFilter::Components::SimpleParser.new
    end
    
    it "#parse_attributes matches html attributes" do
      attributes = {'name' => 'blog/recent_articles', 'section_id' => '1', 'count' => '5'}
      @parser.send(:parse_attributes, @html).should == attributes
    end
    
    it "#components returns an array with component/state and attributes" do
      @parser.components(@html).should == @components
    end
  end
end
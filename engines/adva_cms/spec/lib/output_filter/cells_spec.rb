require File.dirname(__FILE__) + '/../../spec_helper'

describe OutputFilter::Cells do
  before :each do
    @filter = OutputFilter::Cells.new

    @html = <<-html
      <html>
        <body>
          <cell controller="blog" name="best_articles" section_id="1" count="10" />
          <cell controller="blog" name="recent_articles" section_id="1" count="5" />
          something>invalid
        </body>
      </html>
    html

    @cells = { '<cell controller="blog" name="best_articles" section_id="1" count="10" />'  => 
                 ['blog', 'best_articles', {'section_id' => '1', 'count' => '10'}],
               '<cell controller="blog" name="recent_articles" section_id="1" count="5" />' => 
                 ['blog', 'recent_articles', {'section_id' => '1', 'count' => '5'}] }
  end
  
  describe '#after' do
    before :each do
      response    = mock 'response', :body => @html, :template => mock('template', :render_cell => 'cell rendered')
      @controller = mock 'controller', :response => response
    end
    
    it "renders the cells" do
      @cells.each do |tag, cell|
        @controller.response.template.should_receive(:render_cell).with(*cell)
      end
      @filter.after(@controller)
    end
    
    it "replaces the cell tags with rendering results" do
      @filter.after(@controller)
      @controller.response.body.scan(/cell rendered/).should have(2).things
    end
  end
  
  describe 'SimpleParser' do
    before :each do
      @parser = OutputFilter::Cells::SimpleParser.new
    end
    
    it "#parse_attributes matches html attributes" do
      attributes = {'controller' => 'blog', 'name' => 'recent_articles', 'section_id' => '1', 'count' => '5'}
      @parser.send(:parse_attributes, @html).should == attributes
    end
    
    it "#cells returns an array with cell_controller, cell_name and attributes" do
      @parser.cells(@html).should == @cells
    end
  end
end
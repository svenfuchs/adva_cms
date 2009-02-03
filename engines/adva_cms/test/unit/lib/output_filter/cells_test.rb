require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class CellsOutputFilterTest < ActionController::TestCase
  tests BaseController

  def setup
    super
    @html = <<-html
      <html>
        <body>
          <cell name="blog/best_articles" section_id="1" count="10" />
          <cell name="blog/recent_articles" section_id="1" count="5" />
          something>invalid
        </body>
      </html>
    html

    @cells = {
      '<cell name="blog/best_articles" section_id="1" count="10" />'  =>
        ['blog', 'best_articles', {'section_id' => '1', 'count' => '10'}],
      '<cell name="blog/recent_articles" section_id="1" count="5" />' =>
        ['blog', 'recent_articles', {'section_id' => '1', 'count' => '5'}]
    }

    @filter = OutputFilter::Cells.new
    @parser = OutputFilter::Cells::SimpleParser.new

    @controller.response = ActionController::TestResponse.new
    @controller.response.body = @html
  end

  test "#after renders the cells and replaces the cell tags with rendering results" do
    @cells.each do |tag, cell|
      mock(@controller.response.template).render_cell(*cell).returns 'cell rendered'
    end
    @filter.after(@controller)
    @controller.response.body.scan(/cell rendered/).size.should == 2
  end

  test "SimpleParser#parse_attributes matches html attributes" do
    attributes = {'name' => 'blog/recent_articles', 'section_id' => '1', 'count' => '5'}
    @parser.send(:parse_attributes, @html).should == attributes
  end
  
  test "SimpleParser#cells returns an array with cell/state and attributes" do
    @parser.cells(@html).should == @cells
  end
end
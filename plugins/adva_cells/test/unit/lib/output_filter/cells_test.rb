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
          <cell name="blog/related_articles" count="5"><section>Company blog</section></cell>
          something>invalid
        </body>
      </html>
    html

    @cells = {
      '<cell name="blog/best_articles" section_id="1" count="10" />'  =>
        ['blog', 'best_articles', {'section_id' => '1', 'count' => '10'}],
      '<cell name="blog/recent_articles" section_id="1" count="5" />' =>
        ['blog', 'recent_articles', {'section_id' => '1', 'count' => '5'}],
      '<cell name="blog/related_articles" count="5"><section>Company blog</section></cell>' =>
        ['blog', 'related_articles', {'section' => 'Company blog', 'count' => '5'}]
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
    @controller.response.body.scan(/cell rendered/).size.should == 3
  end

  test "SimpleParser#cells returns an array with cell/state and attributes" do
    @parser.cells(@html).should == @cells
  end
end
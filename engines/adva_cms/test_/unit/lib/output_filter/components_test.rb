require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class ComponentsOutputFilterTest < ActionController::TestCase
  tests BaseController

  def setup
    super
    @html = <<-html
      <html>
        <body>
          <component name="blog/best_articles" section_id="1" count="10" />
          <component name="blog/recent_articles" section_id="1" count="5" />
          something>invalid
        </body>
      </html>
    html

    @components = {
      '<component name="blog/best_articles" section_id="1" count="10" />'  =>
        ['blog/best_articles', {'section_id' => '1', 'count' => '10'}],
      '<component name="blog/recent_articles" section_id="1" count="5" />' =>
        ['blog/recent_articles', {'section_id' => '1', 'count' => '5'}]
    }

    @filter = OutputFilter::Components.new
    @parser = OutputFilter::Components::SimpleParser.new

    @controller.response = ActionController::TestResponse.new
    @controller.response.body = @html
  end

  test "#after renders the components and replaces the component tags with rendering results" do
    @components.each do |tag, component|
      mock(@controller.response.template).component(*component).returns 'component rendered'
    end
    @filter.after(@controller)
    @controller.response.body.scan(/component rendered/).size.should == 2
  end

  test "SimpleParser#parse_attributes matches html attributes" do
    attributes = {'name' => 'blog/recent_articles', 'section_id' => '1', 'count' => '5'}
    @parser.send(:parse_attributes, @html).should == attributes
  end

  test "SimpleParser#components returns an array with component/state and attributes" do
    @parser.components(@html).should == @components
  end
end
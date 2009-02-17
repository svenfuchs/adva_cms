require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class FooFormBuilder < ExtensibleFormBuilder
end

module ExtensibleFormsBuilderTests
  class RailsExtTest < ActionView::TestCase
    tests ActionView::Helpers::FormHelper
  
    def setup
      super
      @article = Article.new :title => 'article title'
      @controller = Class.new { def url_for(options); 'url' end }.new
    end
  
    def build_form(&block)
      block ||= Proc.new { |f| concat f.field_set { f.text_field(:title) } }
      form_for(:article, @article, :builder => ExtensibleFormBuilder, &block) 
      output_buffer
    end
    
    test "renders a fieldset" do
      build_form =~ /<fieldset/
    end 
  
    test "adds a default id to the a fieldset" do
      build_form =~ /id="article_default"/
    end 
    
    test "adds a custom id to the a fieldset" do
      build_form { |f| concat f.field_set(:foo) } =~ /id="article_foo"/
    end 
    
    test "picks a formbuilder for given object_name" do
      pick_form_builder(:foo).should == FooFormBuilder
    end
  
    protected
  
      def protect_against_forgery?
        false
      end
  end

  class CoreTest < ActionView::TestCase
    tests ActionView::Helpers::FormHelper
  
    def setup
      super
      @article = Article.new :title => 'article title'
      @controller = Class.new { def url_for(options); 'url' end }.new
      @builder = ExtensibleFormBuilder.new(nil, nil, self, {}, nil)
      ExtensibleFormBuilder.options[:labels] = true
    end
  
    def teardown
      reset_form_callbacks
    end
  
    def build_form(*args)
      options = args.extract_options!
      method = args.shift || :title
      form_for(:article, @article, :builder => ExtensibleFormBuilder) do |f|
        concat f.text_field(method, options)
      end
      output_buffer
    end
  
    test "builds the form" do
      assert build_form =~ /<input id="article_title"/
    end
      
    test "adds a label when labels enabled" do
      assert build_form =~ /label/
    end
      
    test "does not add a label when labels disabled" do
      ExtensibleFormBuilder.options[:labels] = false
      assert build_form !~ /label/
    end
      
    test "extracts the id from generated tag (sigh)" do
      assert_equal 'article_title', @builder.send(:extract_id, build_form)
    end

    test "uses the given label option as label text (when labels enabled)" do
      assert build_form(:label => 'the article label') =~ /<label for="article_title">the article label/
    end
      
    test "registers before and after callbacks (given as block or string)" do
      builder = ExtensibleFormBuilder
      assert_nothing_raised do
        builder.before(:article, :title) { |f| 'before!' }
        builder.after(:article, :title, 'after!')
      end
      assert_equal 1, builder.callbacks[:before][:article][:title].size
      assert_equal 1, builder.callbacks[:after][:article][:title].size
    end
  
    test "run_callbacks returns concatenated callback results (given as block or string)" do
      2.times { ExtensibleFormBuilder.before(:article, :title) { 'before!' } }
      2.times { ExtensibleFormBuilder.after(:article, :title, 'after!') }
      @builder.object_name = 'article'
      assert_equal 'before!before!', @builder.send(:run_callbacks, :before, :title)
      assert_equal 'after!after!',   @builder.send(:run_callbacks, :after, :title)
    end
  
    test "with_callbacks returns the concatenated callback results enclosing the passed block's result" do
      ExtensibleFormBuilder.before(:article, :article_title) { 'before!' }
      ExtensibleFormBuilder.after(:article, :article_title, 'after!')
      @builder.object_name = 'article'
      assert_equal 'before!foo!after!', @builder.send(:with_callbacks, :article_title) { 'foo!' }
    end
      
    test "renders tag with callbacks" do
      ExtensibleFormBuilder.before(:article, :title) { 'before!' }
      ExtensibleFormBuilder.after(:article, :title, 'after!')
      expected = '<form action="url" method="post">' +
                 'before!<p><label for="article_title">Title</label>' +
                 '<input id="article_title" name="article[title]" size="30" type="text" value="article title" /></p>' +
                 'after!</form>'
      assert_equal expected, build_form
    end
      
    test "generates a fieldset with legend" do
      expected = '<fieldset id="foo"><legend>legend</legend>bar</fieldset>'
      assert_equal expected, @builder.field_set(:id => 'foo', :legend => 'legend') { 'bar' }
    end
      
    test "fieldset generation works within formbuilder block (labels enabled)" do
      form_for(:article, @article, :builder => ExtensibleFormBuilder) do |f|
        f.field_set(:id => 'foo') { concat f.text_field(:title) }
      end
      expected = '<form action="url" method="post">' +
                 '<fieldset id="foo"><p><label for="article_title">Title</label>' +
                 '<input id="article_title" name="article[title]" size="30" type="text" value="article title" /></p>' +
                 '</fieldset></form>'
      
      assert_equal expected, output_buffer
    end
      
    protected
  
      def protect_against_forgery?
        false
      end
  
      def reset_form_callbacks
        ExtensibleFormBuilder.callbacks = { :before => {}, :after => {} }
      end
  end
  
  class RenderTest < ActionController::TestCase
    tests Admin::InstallController
  
    describe "ExtensibleFormsBuilder" do
      action { get :index }
      before { register_form_callbacks }
      after  { reset_form_callbacks }
  
      with :no_site, :no_user do
        it "inserts the callbacks results to the form" do
          @response.body.should =~ /before site name!/
          @response.body.should =~ /after section title!/
        end
      end
    end
  
    def register_form_callbacks
      ExtensibleFormBuilder.before(:site, :name) do |f|
        'before site name!'
      end
      ExtensibleFormBuilder.after(:section, :title) do |f|
        'after section title!'
      end
    end
  
    def reset_form_callbacks
      ExtensibleFormBuilder.callbacks = { :before => {}, :after => {} }
    end
  end
end
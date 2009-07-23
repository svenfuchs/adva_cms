require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class FooFormBuilder < ExtensibleFormBuilder
end

class TestFormBuilder < ExtensibleFormBuilder
  def self.reset!
    self.labels = true
    self.wrap = true
    self.default_class_names.clear
  end
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
      form_for(:article, @article, :builder => TestFormBuilder, &block)
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

    attr_reader :controller
    attr_reader :assigns

    def setup
      super
      @article = Article.new :title => 'article title'
      @controller = Class.new { def url_for(options); 'url' end }.new
      @builder = TestFormBuilder.new(nil, nil, self, {}, nil)
      @assigns = {}
      TestFormBuilder.reset!
    end

    def teardown
      reset_form_callbacks
    end

    def build_form(*args)
      options = args.extract_options!
      method = args.shift || :title
      form_for(:article, @article, :builder => TestFormBuilder) do |f|
        concat f.text_field(method, options)
      end
      output_buffer
    end

    test "builds the form" do
      assert build_form =~ /<input id="article_title"/
    end

    # options

    test "adds a label when labels enabled" do
      assert build_form =~ /label/
    end

    test "does not add a label when labels disabled" do
      TestFormBuilder.options[:labels] = false
      assert build_form !~ /label/
    end

    test "adds default_class_names to the generated text_field" do
      TestFormBuilder.default_class_names(:text_field) << 'default class names'
      assert build_form =~ /<input class="default class names"/
    end

    test "adds default_class_names to the generated fieldset" do
      TestFormBuilder.default_class_names(:field_set) << 'default class names'
      expected = '<fieldset class="bar default class names" id="foo"><legend>legend</legend>baz</fieldset>'
      assert_equal expected, @builder.field_set(:id => 'foo', :legend => 'legend', :class => 'bar') { 'baz' }
    end

    # labels

    test "uses the given string as label text (labels enabled)" do
      assert build_form(:label => 'the article label') =~ /<label for="article_title">the article label/
    end

    test "translates the given symbol and uses it as label text (labels enabled)" do
      assert build_form(:label => :'activerecord.errors.messages.invalid') =~ /<label for="article_title">is invalid/
    end

    test "uses the ActiveRecord namespace's translation as label text when label option is true" do
      I18n.backend.store_translations(:en, { :activerecord => { :attributes => { :article => { :body => "Text" } } } })
      assert build_form(:body, :label => true) =~ /<label for="article_body">Text/
    end

    test "uses the humanized method name as label text when label option is true and no translation can be found in ActiveRecord namespace (labels enabled)" do
      assert build_form(:label => true) =~ /<label for="article_title">Title/
    end

    # callbacks

    test "registers before and after callbacks (given as block or string)" do
      builder = TestFormBuilder
      assert_nothing_raised do
        builder.before(:article, :title) { |f| 'before!' }
        builder.after(:article, :title, 'after!')
      end
      assert_equal 1, builder.callbacks[:before][:article][:title].size
      assert_equal 1, builder.callbacks[:after][:article][:title].size
    end

    test "run_callbacks returns concatenated callback results (given as block or string)" do
      2.times { TestFormBuilder.before(:article, :title) { 'before!' } }
      2.times { TestFormBuilder.after(:article, :title, 'after!') }
      @builder.object_name = 'article'
      assert_equal 'before!before!', @builder.send(:run_callbacks, :before, :title)
      assert_equal 'after!after!',   @builder.send(:run_callbacks, :after, :title)
    end

    test "with_callbacks returns the concatenated callback results enclosing the passed block's result" do
      TestFormBuilder.before(:article, :article_title) { 'before!' }
      TestFormBuilder.after(:article, :article_title, 'after!')
      @builder.object_name = 'article'
      assert_equal 'before!foo!after!', @builder.send(:with_callbacks, :article_title) { 'foo!' }
    end

    test "renders tag with callbacks" do
      TestFormBuilder.before(:article, :title) { 'before!' }
      TestFormBuilder.after(:article, :title, 'after!')
      expected = '<form action="url" method="post">' +
                 'before!<p><label for="article_title">Title</label>' +
                 '<input id="article_title" name="article[title]" size="30" tabindex="1" type="text" value="article title" /></p>' +
                 'after!</form>'
      assert_equal expected, build_form
    end

    # fieldset

    test "generates a fieldset with legend" do
      expected = '<fieldset class="bar" id="foo"><legend>legend</legend>baz</fieldset>'
      assert_equal expected, @builder.field_set(:id => 'foo', :legend => 'legend', :class => 'bar') { 'baz' }
    end

    test "fieldset generation works within formbuilder block (labels and hints enabled)" do
      form_for(:article, @article, :builder => TestFormBuilder) do |f|
        concat f.text_field(:title)
        f.field_set(:id => 'foo') { concat f.text_field(:title, :hint => 'hint for title') }
      end
      expected = '<form action="url" method="post">' +
                 '<p><label for="article_title">Title</label>' +
                 '<input id="article_title" name="article[title]" size="30" tabindex="1" type="text" value="article title" /></p>' +
                 '<fieldset id="foo">' +
                 '<p><label for="article_title">Title</label>' +
                 '<input id="article_title" name="article[title]" size="30" tabindex="2" type="text" value="article title" />' +
                 '<span class="hint" for="article_title">hint for title</span></p>' +
                 '</fieldset></form>'
      assert_equal expected, output_buffer
    end

    test "extracts the id from generated tag (sigh)" do
      assert_equal 'article_title', @builder.send(:extract_id, build_form)
    end
    
    # tabindexes
    
    test "adds a tabindex" do
      assert build_form =~ /tabindex="1"/
    end
    
    test "adds user specified tabindex" do
      assert build_form(:body, :tabindex => 666) =~ /tabindex="666"/
    end
    
    test "increments tabindexes for multiple form fields" do
      form_for(:article, @article, :builder => TestFormBuilder) do |f|
        concat f.text_field(:title)
        concat f.text_area(:body)
      end
      expected = '<form action="url" method="post">' +
                 '<p><label for="article_title">Title</label>' +
                 '<input id="article_title" name="article[title]" size="30" tabindex="1" type="text" value="article title" />' +
                 '</p><p><label for="article_body">Body</label>' +
                 '<textarea cols="40" id="article_body" name="article[body]" rows="20" tabindex="2"></textarea>' +
                 '</p></form>'
      assert_equal expected, output_buffer
    end

    test "uses field id to remember the tab indexes of form fields" do
      @builder.text_field(:title, :tabindex => 43)
      @builder.text_area(:body, :tabindex => 433)
      assert @builder.send(:tabindexes) == { :_title => 43, :_body => 433 }
    end

    test "does not remember tab index if field id is empty" do
      @builder.text_field(:title, :id => "", :tabindex => 43)
      @builder.text_area(:body, :id => "", :tabindex => 433)
      assert @builder.send(:tabindexes) == { }
    end
    
    test "uses the same tabindex as the form field with the id of given symbol" do
      form_for(:article, @article, :builder => TestFormBuilder) do |f|
        concat f.text_field(:title, :tabindex => 4)
        concat f.text_area(:body, :tabindex => :article_title)
      end
      expected = '<form action="url" method="post">' +
                 '<p><label for="article_title">Title</label>' +
                 '<input id="article_title" name="article[title]" size="30" tabindex="4" type="text" value="article title" />' +
                 '</p><p><label for="article_body">Body</label>' +
                 '<textarea cols="40" id="article_body" name="article[body]" rows="20" tabindex="4"></textarea>' +
                 '</p></form>'
      assert_equal expected, output_buffer
    end

    test "decrements the tabindex by one if defined by { :before => :article_title }" do
      form_for(:article, @article, :builder => TestFormBuilder) do |f|
        concat f.text_field(:title, :tabindex => 4)
        concat f.text_area(:body, :tabindex => { :before => :article_title })
      end
      expected = '<form action="url" method="post">' +
                 '<p><label for="article_title">Title</label>' +
                 '<input id="article_title" name="article[title]" size="30" tabindex="4" type="text" value="article title" />' +
                 '</p><p><label for="article_body">Body</label>' +
                 '<textarea cols="40" id="article_body" name="article[body]" rows="20" tabindex="3"></textarea>' +
                 '</p></form>'
      assert_equal expected, output_buffer
    end
    
    test "increments the tabindex by one if defined by { :after => :article_title }" do
      form_for(:article, @article, :builder => TestFormBuilder) do |f|
        concat f.text_field(:title, :tabindex => 4)
        concat f.text_area(:body, :tabindex => { :after => :article_title })
      end
      expected = '<form action="url" method="post">' +
                 '<p><label for="article_title">Title</label>' +
                 '<input id="article_title" name="article[title]" size="30" tabindex="4" type="text" value="article title" />' +
                 '</p><p><label for="article_body">Body</label>' +
                 '<textarea cols="40" id="article_body" name="article[body]" rows="20" tabindex="5"></textarea>' +
                 '</p></form>'
      assert_equal expected, output_buffer
    end
    
    protected

      def protect_against_forgery?
        false
      end

      def reset_form_callbacks
        TestFormBuilder.callbacks = { :before => {}, :after => {} }
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

  class TabRenderTest < ActionView::TestCase
    include UrlHelper
    
    attr_accessor :controller

    def setup
      Rails.backtrace_cleaner.remove_silencers!
      ExtensibleFormBuilder.tabs = []
      ExtensibleFormBuilder.tab(:foo) do |f|
        'that foo tabby!'
      end
      ExtensibleFormBuilder.tab(:bar) do |f|
        'that bar tabby!'
      end
      @controller = ActionController::Base.new
      @form = ExtensibleFormBuilder.new(nil, nil, self, {}, nil)
      super
    end

    def assigns
      {}
    end
    
    def concat(string)
      string
    end

    test "calls the registered block for the tab" do
      tabs = @form.tabs
      assert_match %r(that foo tabby!), tabs
      assert_match %r(that bar tabby!), tabs
    end
    
    test "wraps the tab into a div with appropriate class and id" do
      tabs = @form.tabs
      assert_html tabs, 'div[class=tabs]' do
        assert_select 'ul' do
          assert_select 'li a[href=#foo]'
          assert_select 'li a[href=#bar]'
        end
        assert_select 'div[class=tab active][id=tab_foo]'
        assert_select 'div[class=tab][id=tab_bar]'
      end
    end
    
    # test "calls before and after callbacks for each tab" do
    #   mock(@form).run_callbacks(:before, :'tab_foo').returns ''
    #   mock(@form).run_callbacks(:before, :'tab_bar').returns ''
    #   mock(@form).run_callbacks(:after, :'tab_foo').returns ''
    #   mock(@form).run_callbacks(:after, :'tab_bar').returns ''
    #   @form.tabs
    # end
  end
end
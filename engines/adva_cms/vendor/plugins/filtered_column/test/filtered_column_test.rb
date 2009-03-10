require File.join(File.dirname(__FILE__), 'abstract_unit')

class FilteredColumnTest < Test::Unit::TestCase
  {
    :textile  => { :input  => '*foo*',        :output => '<p><strong>foo</strong></p>' },
    :markdown => { :input  => "# bar\n\nfoo", :output => "<h1>bar</h1>\n\n<p>foo</p>" },
    :smartypants => { :input => "\"abc\" `<def ghi=\"jkl\">`\n\n    <mno pqr=\"stu\">...</mno>",
      :output => "<p>&#8220;abc&#8221; <code>&lt;def ghi=\"jkl\"&gt;</code></p>\n\n<pre><code>&lt;mno pqr=\"stu\"&gt;...&lt;/mno&gt;\n</code></pre>" },
  }.each do |filter_name, values|
    define_method "test_should_filter_with_#{filter_name}" do
      assert_equal values[:output], FilteredColumn::Processor.new("#{filter_name}_filter", values[:input]).filter
    end

    define_method "test_should_filter_model_attribute_with_#{filter_name}" do
      assert_filters_called_on "#{filter_name}_filter".to_sym do
        a = Article.create :body => values[:input], :filter => "#{filter_name}_filter"
        assert_equal values[:output], a.body_html
      end
    end
  end
  
  def test_should_retrieve_filter
    assert_equal FilteredColumn::Filters::TextileFilter, FilteredColumn.filters[:textile_filter]
  end

  def test_should_use_default_filter_names
    assert_equal 'Textile',  FilteredColumn::Filters::TextileFilter.filter_name
    assert_equal 'Markdown', FilteredColumn::Filters::MarkdownFilter.filter_name
  end

  def test_should_allow_filter_name_customization
    assert_equal 'Markdown with Smarty Pants', FilteredColumn::Filters::SmartypantsFilter.filter_name
  end
 
  def test_should_use_default_filter_keys
    assert_equal :textile_filter,     FilteredColumn::Filters::TextileFilter.filter_key
    assert_equal :markdown_filter,    FilteredColumn::Filters::MarkdownFilter.filter_key
    assert_equal :smartypants_filter, FilteredColumn::Filters::SmartypantsFilter.filter_key
  end

  def test_should_call_no_filters_with_no_data
    assert_no_filters_called_on(Article) { Article.new }
  end
  
  def test_should_escape_textile_filter
    assert_equal '<notextile>foo</notextile>', FilteredColumn::Filters::TextileFilter.escape('foo')
  end
  
  def test_should_parse_content_with_html_tokenizer
    article = Article.create :body => '*foo*', :filter => "textile_filter"
    assert_kind_of HTML::Document, article.body_doc
  end
end

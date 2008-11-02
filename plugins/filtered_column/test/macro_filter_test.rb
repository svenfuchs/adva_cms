require File.join(File.dirname(__FILE__), 'abstract_unit')

class MacroFilterTest < Test::Unit::TestCase
  def test_should_retrieve_macro
    assert_equal SampleMacro, FilteredColumn.macros[:sample_macro]
  end
  
  def test_sample_macro
    assert_equal %(foo:  - flip:  - text: test), process_macros("<macro:sample>test</macro:sample>")
  end

  def test_sample_macro_with_attributes
    assert_equal %(foo: foo - flip: bar - text: test), process_macros(%(<macro:sample foo="foo" flip="bar">test</macro:sample>))
  end

  def test_sample_macro_with_underscored_attributes
    assert_equal %(foo: foo - flip: bar - text: test), process_macros(%(<macro:sample foo_bar="foo" flip="bar">test</macro:sample>))
  end
  
  def test_should_escape_macros_with_textile
    assert_equal %(foo:  - flip:  - text: <tt>test</tt>), process_filter(:textile_filter, "<macro:sample><tt>test</tt></macro:sample>")
  end
end
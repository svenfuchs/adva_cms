require File.dirname(__FILE__) + '/test_helper'

class TagListTest < ActiveSupport::TestCase
  teardown do
    TagList.delimiter = ' '
  end
  
  test "#from leaves arguments unchanged" do
    tags = '"One  ", Two'
    original = tags.dup
    TagList.from(tags)
    assert_equal tags, original
  end
  
  test "#from with a single tag name" do
    assert_equal %w(Fun), TagList.from("Fun")
  end
  
  test "#from with a single quoted tag name" do
    assert_equal %w(Fun), TagList.from('"Fun"')
  end
  
  test "#from with a single blank tag name" do
    assert_equal [], TagList.from(nil)
    assert_equal [], TagList.from("")
  end
  
  test "#from with tags contained in quoted tags" do
    assert_equal ['foo bar', 'bar'], TagList.from('"foo bar" bar')
  end
  
  test "#from with a single quoted tag name that includes a comma (with comma delimiter)" do
    TagList.delimiter = ','
    assert_equal ['with, comma'], TagList.from('"with, comma"')
  end
  
  test "#from does not delineate spaces (with comma delimiter)" do
    TagList.delimiter = ','
    assert_equivalent ['A B', 'C'], TagList.from('A B, C')
  end
  
  test "#from with multiple tags" do
    assert_equivalent %w(Alpha Beta Delta Gamma), TagList.from("Alpha Beta Delta Gamma")
  end
  
  test "#from with multiple tags with quotes and multiple spaces" do
    assert_equivalent %w(Alpha Beta Delta Gamma), TagList.from('Alpha  "Beta"  Gamma   "Delta"')
  end
  
  test "#from with multiple tags with single quotes" do
    assert_equivalent ['A B', 'C'], TagList.from("'A B' C")
  end
  
  test "#from with multiple tags with quotes and commas (with comma delimiter)" do
    TagList.delimiter = ','
    assert_equivalent ['Alpha, Beta', 'Delta', 'Gamma, something'], TagList.from('"Alpha, Beta", Delta, "Gamma, something"')
  end
  
  test "#from removes leading/trailing whitespace from tag names" do
    assert_equivalent %w(Alpha Beta), TagList.from('" Alpha   " "Beta  "')
    assert_equivalent %w(Alpha Beta), TagList.from('  Alpha  Beta ')
  end
  
  test "#from removes duplicate tags" do
    assert_equal %w(One), TagList.from("One One")
  end
  
  test "#to_s (with comma delimiter)" do
    TagList.delimiter = ','
    assert_equal "Question, Crazy Animal", TagList.new("Question", "Crazy Animal").to_s
  end
  
  test "#to_s (with space delimiter)" do
    assert_equal '"Crazy Animal" Question', TagList.new("Crazy Animal", "Question").to_s
  end
  
  test "#add" do
    tag_list = TagList.new("One")
    assert_equal %w(One), tag_list
    
    assert_equal %w(One Two), tag_list.add("Two")
    assert_equal %w(One Two Three), tag_list.add(["Three"])
  end
  
  test "#remove" do
    tag_list = TagList.new("One", "Two")
    assert_equal %w(Two), tag_list.remove("One")
    assert_equal %w(), tag_list.remove(["Two"])
  end
  
  test "#new with parsing" do
    assert_equal %w(One Two), TagList.new("One Two", :parse => true)
  end
  
  test "#add with parsing" do
    assert_equal %w(One Two), TagList.new.add("One Two", :parse => true)
  end
  
  test "#remove with parsing" do
    tag_list = TagList.from("Three Four Five")
    assert_equal %w(Four), tag_list.remove("Three Five", :parse => true)
  end
end

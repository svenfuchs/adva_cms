require File.dirname(__FILE__) + "/../test_helper"

module TagsTests
  class TagTest < ActiveSupport::TestCase
    test 'tag_name uses the class name when no tag_name has been defined on subclass' do
      assert_equal :span, Tags::Span.new.tag_name
    end

    test 'can render an empty tag' do
      assert_html Tags::Span.new.render, 'span'
    end
  end
end
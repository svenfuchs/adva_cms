$:.unshift File.expand_path(File.dirname(__FILE__) + '/../app/helpers')
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'meta_tags_helper'

require 'rubygems'
require 'action_controller'
require 'action_view'
require 'action_view/test_case'

class RailsExtTest < ActionView::TestCase
  class MetaTagThingy
    attr_accessor :meta_author, :meta_geourl, :meta_copyright, :meta_keywords, :meta_description
    def initialize(*args)
      @meta_author, @meta_geourl, @meta_copyright, @meta_keywords, @meta_description = *args
    end
  end

  class MetaTagThingyController
    def current_resource
      MetaTagThingy.new("the author", "the geourl", "the copyright", "the keywords", "the description")
    end
  end

  tests MetaTagsHelper

  def setup
    super
    @controller = MetaTagThingyController.new
    @resource = MetaTagThingy.new("the author", "the geourl", "the copyright", "the keywords", "the description")
    @tags = meta_tags(@resource).split(/\n/)
  end

  test "returns meta tags as expected" do
    assert Array === @tags
    assert_equal 5, @tags.size
    assert_equal '<meta content="the author" name="author" />', @tags.first
  end

  test "#meta_value_from returns first non-blank value" do
    assert_equal 'foo', meta_value_from(nil, '', 'foo')
  end
end
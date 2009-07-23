require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../../../lib')
require 'routing_filter/section_paths'

module RoutingFilterTests
  class SectionsTest < ActiveSupport::TestCase
    def setup
      super
      @site = Site.first
      @section = @site.sections.find_by_title('a page')
      @sorted_section_paths = @site.sections.paths.sort{|a, b| b.size <=> a.size }.join('|')
      @filter = RoutingFilter::SectionPaths.new({})
      @base_route = "http://www.bogus.info"
    end
    
    # Protected methods
    
    test "paths_for_site sorts and returns all the section paths for the site" do
      assert_equal @sorted_section_paths, @filter.send(:paths_for_site, @site)
    end
    
    test "paths_for_site returns an empty array if no site is given" do
      assert_equal [], @filter.send(:paths_for_site, nil)
    end
    
    test "section_by_path detects the section from path - standard paths" do
      %w( an-unpublished-section another-page letter-test an-album öäü a-page ).each do |pattern|
        assert @filter.send(:section_by_path, @site, pattern)
      end
    end
  end
end
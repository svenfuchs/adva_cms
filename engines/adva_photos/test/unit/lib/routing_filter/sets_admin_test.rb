require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../../../../adva_cms/lib')
require 'routing_filter/sets'

module RoutingFilterTests
  class SetsAdminTest < ActiveSupport::TestCase
    def setup
      super
      @filter = RoutingFilter::Sets.new({})
      album = Album.first
      site  = album.site
      set   = album.sets.first
      @types           = Section.types.map{|type| type.downcase.pluralize }.join('|')
      @set_path        = "/admin/sites/#{site.id}/sections/#{album.id}/sets/#{set.id}/edit"
      @set_locale_path = "/de/admin/sites/#{site.id}/sections/#{album.id}/sets/#{set.id}/edit"
    end
    
    # around_recognize
    
    test "#around_recognize does not do any filtering if url starts with /admin" do
      mock(@filter).match_path(@set_path, @types).times(0)
      
      @filter.around_recognize(@set_path, 'test') { }
    end
    
    test "#around_recognize does not do any filtering if url starts with, for example - /de/admin" do
      mock(@filter).match_path(@set_locale_path, @types).times(0)
      
      @filter.around_recognize(@set_locale_path, 'test') { }
    end
    
    # around_generate
    
    test "#around_generate does not do any filtering if url starts with /admin" do
      assert_equal @filter.around_generate { @set_path.dup }, @set_path
    end
    
    test "#around_generate does not do any filtering if url starts with, for example - /de/admin" do
      assert_equal @filter.around_generate { @set_locale_path.dup }, @set_locale_path
    end
  end
end
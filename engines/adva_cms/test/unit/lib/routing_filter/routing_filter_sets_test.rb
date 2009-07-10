require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../../../lib')
require 'routing_filter/sets'

module RoutingFilterTests
  class SetsTest < ActiveSupport::TestCase
    def setup
      super
      @filter = RoutingFilter::Sets.new({})
      @base_route = "/albums/1/sets/"
    end
  
    test "filter is a sets routing filter" do
      assert @filter.is_a?(RoutingFilter::Sets)
    end
  
    test "it correctly recognizes the set from url - standard set" do
      standard_set.each do |route|
        assert_equal 'a-set', @filter.match_path(@base_route + route, ['albums'])[2]
      end
    end
  
    test "it correctly recognizes the set from url - child set" do
      child_set.each do |route|
        assert_equal 'a-set/child', @filter.match_path(@base_route + route, ['albums'])[2]
      end
    end
  
    test "it correctly recognizes the set from url - set with digit" do
      set_with_digit.each do |route|
        assert_equal 'set-666', @filter.match_path(@base_route + route, ['albums'])[2]
      end
    end
  
    test "it correctly recognizes the set from url - child set with digit" do
      child_set_with_digit.each do |route|
        assert_equal 'set-666/kid69', @filter.match_path(@base_route + route, ['albums'])[2]
      end
    end
  
    test "it correctly recognizes the set from url - set with digits only" do
      digit_set.each do |route|
        assert_equal '1234', @filter.match_path(@base_route + route, ['albums'])[2]
      end
    end
  
    test "it correctly recognizes the set from url - child set with digits only" do
      digit_child_set.each do |route|
        assert_equal '1234/567', @filter.match_path(@base_route + route, ['albums'])[2]
      end
    end
    
    test "it fails to recognize four digit child sets" do
      assert_equal '1234', @filter.match_path(@base_route + "1234/5678", ['albums'])[2]
    end
    
    test "it fails to recognize four and two digit parent child combinations under the root set level" do
      assert_equal '1234/56', @filter.match_path(@base_route + "1234/56", ['albums'])[2]
      assert_equal '1234', @filter.match_path(@base_route + "1234/4567/89", ['albums'])[2]
    end
  
    def standard_set
      %w( a-set a-set/2009/1 a-set/2009/12 a-set.atom a-set.html a-set.pdf )
    end
  
    def child_set
      %w( a-set/child a-set/child/2009/1 a-set/child/2009/12 a-set/child.atom a-set/child.html a-set/child.pdf )
    end
  
    def set_with_digit
      %w( set-666 set-666/2009/1 set-666/2009/12 set-666.atom set-666.html set-666.pdf )
    end
  
    def child_set_with_digit
      %w( set-666/kid69 set-666/kid69/2009/1 set-666/kid69/2009/12 set-666/kid69.atom set-666/kid69.html set-666/kid69.pdf )
    end
  
    def digit_set
      %w( 1234 1234/2009/1 1234/2009/12 1234.atom 1234.html 1234.pdf )
    end
  
    def digit_child_set
      %w( 1234/567 1234/567/2009/1 1234/567/2009/12 1234/567.atom 1234/567.html 1234/567.pdf )
    end
  end
end
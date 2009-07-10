require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../../../lib')
require 'routing_filter/categories'

module RoutingFilterTests
  class CategoriesTest < ActiveSupport::TestCase
    def setup
      super
      @filter = RoutingFilter::Categories.new({})
      @base_route = "/blogs/1/categories/"
    end
  
    test "filter is a categories routing filter" do
      assert @filter.is_a?(RoutingFilter::Categories)
    end
  
    test "it correctly recognizes the category from url - standard category" do
      standard_category.each do |route|
        assert_equal 'a-category', @filter.match_path(@base_route + route, ['blogs'])[2]
      end
    end
  
    test "it correctly recognizes the category from url - child category" do
      child_category.each do |route|
        assert_equal 'a-category/child', @filter.match_path(@base_route + route, ['blogs'])[2]
      end
    end
  
    test "it correctly recognizes the category from url - category with digit" do
      category_with_digit.each do |route|
        assert_equal 'category-666', @filter.match_path(@base_route + route, ['blogs'])[2]
      end
    end
  
    test "it correctly recognizes the category from url - child category with digit" do
      child_category_with_digit.each do |route|
        assert_equal 'category-666/kid69', @filter.match_path(@base_route + route, ['blogs'])[2]
      end
    end
  
    test "it correctly recognizes the category from url - category with digits only" do
      digit_category.each do |route|
        assert_equal '1234', @filter.match_path(@base_route + route, ['blogs'])[2]
      end
    end
  
    test "it correctly recognizes the category from url - child category with digits only" do
      digit_child_category.each do |route|
        assert_equal '1234/567', @filter.match_path(@base_route + route, ['blogs'])[2]
      end
    end
    
    test "it fails to recognize four digit child categories" do
      assert_equal '1234', @filter.match_path(@base_route + "1234/5678", ['blogs'])[2]
    end
    
    test "it fails to recognize four and two digit parent child combinations under the root category level" do
      assert_equal '1234/56', @filter.match_path(@base_route + "1234/56", ['blogs'])[2]
      assert_equal '1234', @filter.match_path(@base_route + "1234/4567/89", ['blogs'])[2]
    end
  
    def standard_category
      %w( a-category a-category/2009 a-category/2009/1 a-category/2009/12 a-category.atom a-category.html a-category.pdf )
    end
  
    def child_category
      %w( a-category/child a-category/child/2009 a-category/child/2009/1 a-category/child/2009/12 a-category/child.atom 
          a-category/child.html a-category/child.pdf )
    end
  
    def category_with_digit
      %w( category-666 category-666/2009 category-666/2009/1 category-666/2009/12 category-666.atom 
          category-666.html category-666.pdf )
    end
  
    def child_category_with_digit
      %w( category-666/kid69 category-666/kid69/2009 category-666/kid69/2009/1 category-666/kid69/2009/12 
          category-666/kid69.atom category-666/kid69.html category-666/kid69.pdf )
    end
  
    def digit_category
      %w( 1234 1234/2009 1234/2009/1 1234/2009/12 1234.atom 1234.html 1234.pdf )
    end
  
    def digit_child_category
      %w( 1234/567 1234/567/2009 1234/567/2009/1 1234/567/2009/12 1234/567.atom 1234/567.html 1234/567.pdf )
    end
  end
end
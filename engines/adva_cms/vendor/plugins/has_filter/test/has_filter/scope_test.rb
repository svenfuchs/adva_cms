require File.dirname(__FILE__) + '/../test_helper.rb'

module HasFilter
  class ScopesTest < ActiveSupport::TestCase
    include HasFilter
    include HasFilter::TestHelper
    
    def setup
      @first  = Article.find_by_title 'first'
      @second = Article.find_by_title 'second'
      @third  = Article.find_by_title 'third'
    end

    test 'text filter applies scopes to multiple attributes' do
      params = { :text => { 
        :title => [{ :scope => :starts_with, :query => 'f' }], 
        :body  => [{ :scope => :contains, :query => 'i' }] } }
      assert_equal [@first], filter_chain.scope(Article, params)
    end

    test 'text filter applies multiple scopes to the same attribute' do
      params = { :text => { 
        :body => [{ :scope => :starts_with, :query => 'f' }, { :scope => :contains, :query => 'ir' }] } }
      assert_equal [@first], filter_chain.scope(Article, params)
    end

    test 'state filter applies multiple state scopes' do
      params = { :state => [:published, :approved] }
      assert_equal [@second], filter_chain.scope(Article, params)
    end
    
    test 'tags filter applies tags scope' do
      params = { :tags => ['foo bar'] }
      assert_equal [@first, @second], filter_chain.scope(Article, params)
    end
  end
end
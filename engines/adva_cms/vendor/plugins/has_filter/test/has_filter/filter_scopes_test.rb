require File.dirname(__FILE__) + '/../test_helper.rb'

module HasFilter
  class FilterScopesTest < ActiveSupport::TestCase
    include HasFilter
    include HasFilter::TestHelper

    def setup
      @first  = HasFilterArticle.find_by_title 'first'
      @second = HasFilterArticle.find_by_title 'second'
      @third  = HasFilterArticle.find_by_title 'third'
      @upcase = HasFilterArticle.find_by_title 'UPCASE'
    end

    test 'text filter applies scopes to an attribute' do
      params = [{ :title     => { :scope => 'contains', :query => 'i' },
                  :body      => { :scope => 'contains', :query => 'x' },
                  :excerpt   => { :scope => 'contains', :query => 'x' },
                  :tagged    => 'x',
                  :selected  => 'title' }]
      assert_equal [@first, @third], HasFilterArticle.filter_chain.select(params).scope
    end
    
    test 'text filter works with translated columns' do
      params = [{ :title     => { :scope => 'is', :query => 'UPCASE' },
                  :body      => { :scope => 'is', :query => 'x' },
                  :excerpt   => { :scope => 'is', :query => 'x' },
                  :tagged    => 'x',
                  :selected  => 'title' }]
      assert_equal [@upcase], HasFilterArticle.filter_chain.select(params).scope
    end
    
    test 'text filter works with upcase letters' do
      HasFilterArticle.stubs(:translated?).with(:title).returns true
      scope = HasFilterArticle.send(:filter_scope, :title, ["first"], "=")
      expected_scope = {:conditions=>["title = ? AND current = ?", "first", true],
                        :joins=>:globalize_translations,
                        :group=>"has_filter_articles.id"}
      assert_equal expected_scope, scope 
    end

    test 'text filter applies scopes to multiple attributes' do
      params = [{ :title     => { :scope => 'starts_with', :query => 'x' },
                  :body      => { :scope => 'starts_with', :query => 'f' },
                  :excerpt   => { :scope => 'starts_with', :query => 'x' },
                  :tagged    => 'x',
                  :selected  => 'body' },
                { :title     => { :scope => 'contains', :query => 'i' },
                  :body      => { :scope => 'contains', :query => 'x' },
                  :excerpt   => { :scope => 'contains', :query => 'x' },
                  :tagged    => 'x',
                  :selected  => 'title' }]
      assert_equal [@first], HasFilterArticle.filter_chain.select(params).scope
    end
    
    test 'text filter applies multiple scopes to the same attribute' do
      params = [{ :title     => { :scope => 'starts_with', :query => 'f' },
                  :body      => { :scope => 'starts_with', :query => 'x' },
                  :excerpt   => { :scope => 'starts_with', :query => 'x' },
                  :tagged    => 'x',
                  :selected  => 'title' },
                { :title     => { :scope => 'contains', :query => 'i' },
                  :body      => { :scope => 'contains', :query => 'x' },
                  :excerpt   => { :scope => 'contains', :query => 'x' },
                  :tagged    => 'x',
                  :selected  => 'title' }]
      assert_equal [@first], HasFilterArticle.filter_chain.select(params).scope
    end
    
    test 'state filter applies multiple state scopes from the same filter' do
      params = [{ :state => [:published, :approved], :selected  => 'state' }] # should in theory be an OR join
      assert_equal [@second], HasFilterArticle.filter_chain.select(params).scope
    end
    
    test 'state filter applies multiple state scopes from different filters' do
      params = [{ :state => [:published], :selected  => 'state' },
                { :state => [:approved], :selected  => 'state' }]
      assert_equal [@second], HasFilterArticle.filter_chain.select(params).scope
    end
    
    test 'tags filter applies tags scope' do
      params = [{ :tagged => ['bar'], :selected => 'tagged' }]
      assert_equal [@first, @second], HasFilterArticle.filter_chain.select(params).scope
    end
    
    test 'categories filter applies categorized scope (1)' do
      params = [{ :categorized => @first.categories.map(&:id), :selected => 'categorized' }]
      assert_equal [@first], HasFilterArticle.filter_chain.select(params).scope
    end
    
    test 'categories filter applies categorized scope (2)' do
      params = [{ :categorized => @second.categories.map(&:id), :selected => 'categorized' }]
      assert_equal [@first, @second], HasFilterArticle.filter_chain.select(params).scope
    end
    
    test 'categories filter applies categorized scope (3)' do
      category = HasFilterCategory.create!(:title => 'new')
      params = [{ :categorized => category.id, :selected => 'categorized' }]
      assert_equal [], HasFilterArticle.filter_chain.select(params).scope
    end
  end
end
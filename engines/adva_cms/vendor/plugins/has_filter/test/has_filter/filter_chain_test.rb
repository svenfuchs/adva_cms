require File.dirname(__FILE__) + '/../test_helper.rb'

module HasFilter
  class FilterChainTest < ActiveSupport::TestCase
    include HasFilter
    include HasFilter::TestHelper
    
    def setup
      @chain = HasFilterArticle.filter_chain
    end

    test 'builds a filter chain with an initial set' do
      assert_equal 'Set', @chain.first.class.name.demodulize
    end
    
    test 'properly duplicates instances when adjusting its size' do
      @chain.send :adjust_size, 2
      first, second = *@chain[0, 2]
      assert_not_equal first.object_id, second.object_id 
      assert_not_equal first.first.object_id, second.first.object_id 
      assert_equal first.object_id, first.first.set.object_id 
      assert_equal second.object_id, second.first.set.object_id 
    end
  end
  
  class FilterSetTest < ActiveSupport::TestCase
    def setup
      @chain = HasFilterArticle.filter_chain
    end

    test 'set has a text filter for each attribute' do
      set = HasFilterArticle.filter_chain.first
      assert_equal %w(body excerpt title), set[0..2].map(&:attribute).map(&:to_s).sort
    end
    
    test 'sorts text filters to the top, not changing their order, followed by the rest ordered by priority' do
      expected = ['Text', 'Text', 'Text', 'Tagged', 'State', 'Categorized']
      assert_equal expected, @chain.first.map{ |filter| filter.class.name.demodulize }
    end
  end
end
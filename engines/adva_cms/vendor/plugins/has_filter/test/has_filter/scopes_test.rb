require File.dirname(__FILE__) + '/../test_helper.rb'

module HasFilter
  class ScopesTest < ActiveSupport::TestCase
    def setup
      @first  = HasFilterArticle.find_by_title 'first'
      @second = HasFilterArticle.find_by_title 'second'
      @third  = HasFilterArticle.find_by_title 'third'
      @upcase = HasFilterArticle.find_by_title 'UPCASE'
    end
  
    test 'scope :is' do
      assert_equal [@first], HasFilterArticle.is(:title, 'first')
    end
  
    test 'scope :is_not' do
      assert_equal [@second, @third, @upcase], HasFilterArticle.is_not(:title, 'first')
    end
  
    test 'scope :contains' do
      assert_equal [@first, @third], HasFilterArticle.contains(:title, 'ir')
    end
      
    test 'scope :does_not_contain' do
      assert_equal [@second, @upcase], HasFilterArticle.does_not_contain(:title, 'ir')
    end
      
    test 'scope :starts_with' do
      assert_equal [@first], HasFilterArticle.starts_with(:title, 'fi')
    end
      
    test 'scope :does_not_start_with' do
      assert_equal [@second, @third, @upcase], HasFilterArticle.does_not_start_with(:title, 'fi')
    end
      
    test 'scope :ends_with' do
      assert_equal [@first], HasFilterArticle.ends_with(:title, 'st')
    end
      
    test 'scope :does_not_end_with' do
      assert_equal [@second, @third, @upcase], HasFilterArticle.does_not_end_with(:title, 'st')
    end
      
    test 'scope :contains_all' do
      assert_equal [@first], HasFilterArticle.contains_all(:title, %w(i r s))
    end
  end
end
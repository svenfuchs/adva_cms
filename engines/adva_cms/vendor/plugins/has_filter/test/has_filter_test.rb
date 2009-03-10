require File.dirname(__FILE__) + '/test_helper.rb'

class HasFilterTest < ActiveSupport::TestCase
  def setup
    @john = Person.find_by_first_name 'John'
    @jane = Person.find_by_first_name 'Jane'
    @rick = Person.find_by_first_name 'Rick'
  end
  
  test 'filter_by :is' do
    assert_equal Person.filter_by(:is, :first_name, 'John'), [@john]
  end
  
  test 'filter_by :is_not' do
    assert_equal Person.filter_by(:is_not, :first_name, 'John'), [@jane, @rick]
  end
  
  test 'filter_by :contains' do
    assert_equal Person.filter_by(:contains, :first_name, 'oh'), [@john]
  end
  
  test 'filter_by :does_not_contain' do
    assert_equal Person.filter_by(:does_not_contain, :first_name, 'oh'), [@jane, @rick]
  end
  
  test 'filter_by :starts_with' do
    assert_equal Person.filter_by(:starts_with, :first_name, 'jo'), [@john]
  end
  
  test 'filter_by :does_not_start_with' do
    assert_equal Person.filter_by(:does_not_start_with, :first_name, 'jo'), [@jane, @rick]
  end
  
  test 'filter_by given an array as value performs an OR condition' do
    assert_equal Person.filter_by(:is, :first_name, ['John', 'Jane']), [@john, @jane]
  end
  
  test 'filter_by given multiple sets of conditions chains scopes (performing an AND condition)' do
    assert_equal Person.filter_by([:is_not, :first_name, 'John'], [:is, :last_name, 'Doe']), [@jane]
  end
  
  test 'filter_by given multiple sets of conditions including arrays as values performs an AND/OR condition' do
    conditions = [[:is, :first_name, ['John', 'Rick']],
                  [:starts_with, :last_name, 'D']]
    assert_equal Person.filter_by(*conditions), [@john]
  end
  
  test 'filter_by throws an exception when an attribute name has been passed that is not whitelisted as filterable' do
    assert_raises(ActiveRecord::IllegalAttributeAccessError) do 
      Person.filter_by(:is, :private_attribute, '')
    end
  end
  
  test 'filter_by does not throw an exception when an arbitrary name was passed that is not an attribute' do
    assert_nothing_raised do 
      Person.filter_by(:is, :not_an_attribute, '')
    end
  end
end
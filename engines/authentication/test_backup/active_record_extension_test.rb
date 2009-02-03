require 'test/unit'
require File.join(File.dirname(__FILE__), 'abstract_unit')

# Test minor enhancements to ActiveRecord
class ActiveRecordExtensionTest < Test::Unit::TestCase
  def test_column_includes
    assert ColumnTest.includes_all_columns?(:foo, :bar)
    assert !ColumnTest.includes_all_columns?(:foo, :boo)
  end
end

class ColumnTest < ActiveRecord::Base
  # Fake the column names
  def self.column_names
    %w(id name foo bar baz)
  end
end
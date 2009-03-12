require 'active_record/connection_adapters/sqlite_adapter'

ActiveRecord::ConnectionAdapters::SQLiteAdapter.class_eval do
  def select_rows_with_tainting(*args)
    returning select_rows_without_tainting(*args) do |result|
      result.map!{|row| row.map! &:taint }
    end
  end
  alias_method_chain :select_rows, :tainting

  def select_with_tainting(*args)
    returning select_without_tainting(*args) do |result|
      result.each do |row|
        row.each{|key, value| row[key] = value.taint }
      end
    end
  end
  alias_method_chain :select, :tainting
end
class AbstractActiveRecord < ActiveRecord::Base
  self.abstract_class = true
  class << self
    def columns
      @columns ||= []
    end    
    def column(name, sql_type = nil, default = nil, null = true)
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
      reset_column_information
    end
  end  
end


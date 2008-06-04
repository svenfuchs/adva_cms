class ActiveRecord::Base
    # Utility method to easily see if the model contains all columns
    # given. Most authentication modules use this to see if they are
    # enabled or not by checking for their required columns.
    def self.includes_all_columns?(*columns)
      columns = columns.flatten.compact
      columns.collect! {|c| c.to_s}

      columns.all? {|c| self.column_names.include? c}
    end
end
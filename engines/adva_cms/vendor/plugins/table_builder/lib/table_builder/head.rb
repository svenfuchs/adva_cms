module TableBuilder
  class Head < Rows
    self.level = 1
    self.tag_name = :thead

    protected
    
      def build
        row = Row.new(self, options)
        table.columns.each do |column| 
          row.cell(column.content, column.options.reverse_merge(:scope => 'col'))
        end
        @rows << row
      end
  end
end
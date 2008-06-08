module Matchers
  module FilterColumn
    def filter_column(*expected)
      FiltersColumn.new(expected)
    end
  
    class FiltersColumn
      def initialize(columns)
        @columns = columns
      end
  
      def matches?(target)
        @target = target
        @columns.each do |column|
          target.send "#{column}=", '*strong*'
          target.should_receive(:filter).any_number_of_times.and_return 'textile_filter'
          target.send :process_filters          
          @result = target.send("#{column}_html")
          @result.should == '<p><strong>strong</strong></p>'
        end
      end

      def failure_message
        "expected #{@target} to filter columns #{columns.to_sentence}. got: #{@result}"
      end
    end
  end
end
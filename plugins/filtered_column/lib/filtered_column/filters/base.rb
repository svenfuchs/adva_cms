module FilteredColumn
  module Filters
    class Base
      class << self
        def filter(text) text end
        def escape(text) text end

        def filter_name
          set_name self.name.demodulize.gsub(/Filter$/, '')
        end
        
        def set_name(name)
          class << self; attr_reader :filter_name ; end
          @filter_name = name
        end
        
        def filter_key
          set_key self.name.demodulize.underscore.to_sym
        end
        
        def set_key(key)
          class << self; attr_reader :filter_key ; end
          @filter_key = key
        end
      end
    end
  end
end
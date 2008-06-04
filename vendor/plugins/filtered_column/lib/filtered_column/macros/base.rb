module FilteredColumn
  module Macros
    class Base
      class << self
        def macro_name
          set_name self.name.demodulize.sub(/Macro$/, '')
        end
        
        def set_name(name)
          class << self; attr_reader :macro_name ; end
          @macro_name = name
        end
        
        def macro_key
          set_key self.name.demodulize.underscore.to_sym
        end
        
        def set_key(key)
          class << self; attr_reader :macro_key ; end
          @macro_key = key
        end
      end
    end
  end
end
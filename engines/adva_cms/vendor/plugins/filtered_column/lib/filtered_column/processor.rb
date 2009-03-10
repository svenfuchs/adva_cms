module FilteredColumn
  @@filters = {}
  @@macros  = {}
  mattr_reader :filters, :macros

  class Processor
    @@patterns = [
      /<(filter|macro|typo):([_a-zA-Z0-9]+)([^>]*)\/>/,
      /<(filter|macro|typo):([_a-zA-Z0-9]+)([^>]*)>(.*?)<\/(filter|macro|typo):([_a-zA-Z0-9]+)>/m
      ].freeze
      
    def self.process_filter(filter_name, text)
      new(filter_name, text).filter
    end
    
    def initialize(filter_name, text)
      @filter = FilteredColumn.filters[filter_name.to_sym] rescue nil
      @text   = text
    end

    def filter
      process_macros
      @filter ? @filter.filter(@text) : @text
    end
    
    protected
      def process_macros
        #RAILS_DEFAULT_LOGGER.warn "PROCESSING MACROS: #{::FilteredColumn.macros.keys.inspect}"
        @@patterns.each do |pattern|
          @text.gsub!(pattern) do |match|
            #RAILS_DEFAULT_LOGGER.warn "our match: #{$2}"
            key = "#{$2}_macro".to_sym
            if !$2.blank? && FilteredColumn.macros.has_key?(key)
              #RAILS_DEFAULT_LOGGER.warn "It has the key!"
              macro = FilteredColumn.macros[key]
              macro_text = macro ? macro.filter(hash_from_attributes($3), $4.to_s) : $4.to_s
              @filter ? @filter.escape(macro_text) : macro_text
            end
          end
        end
      end

      def hash_from_attributes(string)
        attributes = {}
        string.gsub(/([^ =]+="[^"]*")/) do |match|
          key, value = match.split(/=/, 2)
          attributes[key] = value.gsub(/"/, '')
        end
        attributes.symbolize_keys!
      end
  end
end
module FilteredColumn
  module Mixin
    def self.included(base)
      base.extend(ActMethod)
    end
    
    module ActMethod
      # filtered_column :name, :title, :only => [ :textile_filter, :smartypants_filter ]
      def filtered_column(*names)
        unless included_modules.include?(InstanceMethods)
          send :include, InstanceMethods
          class_inheritable_accessor :filtered_attributes, :filtered_options
          before_save :process_filters
        end
        
        options = names.last.is_a?(Hash) ? names.pop : {}
        options[:only]   = [options[:only]].flatten.compact
        options[:except] = [options[:except]].flatten.compact
        names.each do |name|
          (self.filtered_options    ||= {})[name] = options
          (self.filtered_attributes ||= []) << name
          define_method("#{name}_doc") do
            class << self; attr_accessor "#{name}_doc"; end
            instance_variable_set("@#{name}_doc", HTML::Document.new(send("#{name}_html")))
          end
        end
      end

      module InstanceMethods
        protected
          def process_filters
            filtered_attributes.each do |attr_name|
              send "#{attr_name}_html=", FilteredColumn::Processor.process_filter(filter_for_attribute(attr_name), send(attr_name).to_s.dup)
            end
          end
           
          def filter_for_attribute(attr_name)
            return nil if filter.blank? ||
              (!filtered_options[attr_name][:only].blank?   && !filtered_options[attr_name][:only].include?(filter.to_sym)) ||
              (!filtered_options[attr_name][:except].blank? &&  filtered_options[attr_name][:except].include?(filter.to_sym))
            filter
          end
      end
    end
  end
end
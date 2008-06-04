require File.join(File.dirname(__FILE__), 'lib/filtered_column/processor')
require File.join(File.dirname(__FILE__), 'lib/filtered_column/mixin')
require File.join(File.dirname(__FILE__), 'lib/filtered_column/filters/base')
require File.join(File.dirname(__FILE__), 'lib/filtered_column/macros/base')

Dir["#{File.dirname(__FILE__)}/lib/filtered_column/filters/*_filter.rb"].sort.each do |filter_name|
  require filter_name
  klass = File.basename(filter_name).sub(/\.rb/, '')
  FilteredColumn.filters[klass.to_sym] = FilteredColumn::Filters.const_get(klass.classify)
end

# don't even bother until there are default macros
#Dir["#{File.dirname(__FILE__)}/filtered_column/macros/*_macro.rb"].sort.each do |macro_name|
#  FilteredColumn.macros.update(File.basename(macro_name).sub(/\.rb/, '').to_sym => nil)
#end

ActiveRecord::Base.send(:include, FilteredColumn::Mixin)
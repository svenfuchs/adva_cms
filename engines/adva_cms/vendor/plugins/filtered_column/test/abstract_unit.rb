$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment'))
require 'action_controller/vendor/html-scanner/html/document'
require 'breakpoint'

Test::Unit::TestCase.class_eval do
  def assert_filters_called_on(*filters)
    FilteredColumn::Processor.called_filters = []
    filtered = yield
    filtered.save if filtered
    assert_equal filters.length, (FilteredColumn::Processor.called_filters & filters).length, "#{filters.map(&:inspect).join(', ')} expected, #{FilteredColumn::Processor.called_filters.map(&:inspect).join(', ')} called"
  end

  def assert_no_filters_called_on(klass, &block)
    assert_filters_called_on &block
  end

  def process_filter(filter, text)
    FilteredColumn::Processor.new(filter, text).filter
  end
  
  def process_macros(text)
    process_filter nil, text
  end
end

class SampleMacro < FilteredColumn::Macros::Base
  def self.filter(attributes, inner_text = '')
    "foo: #{attributes[:foo] || attributes[:foo_bar]} - flip: #{attributes[:flip]} - text: #{inner_text}"
  end
end

FilteredColumn.macros[:sample_macro] = SampleMacro

FilteredColumn::Processor.class_eval do
  @@called_filters = []
  cattr_accessor :called_filters
  def filter_with_audit
    (called_filters << @filter.filter_key).uniq! if @filter
    filter_without_audit
  end
  alias_method_chain :filter, :audit
end

class Article < ActiveRecord::Base
  def self.columns() @columns ||= []; end
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :body,                           :string
  column :body_html,                      :string
  column :textile_body,                   :string
  column :textile_body_html,              :string
  column :textile_and_markdown_body,      :string
  column :textile_and_markdown_body_html, :string
  column :no_textile_body,                :string
  column :no_textile_body_html,           :string
  column :filter,                         :string
  column :sample_macro_body,              :string
  column :sample_macro_body_html,         :string

  filtered_column :body
  filtered_column :textile_body,              :only   => :textile_filter
  filtered_column :textile_and_markdown_body, :only   => [:textile_filter, :markdown_filter]
  filtered_column :no_textile_body,           :except => :textile_filter
  
  def save
    valid? && send(:callback, :before_save) && true
  end
end
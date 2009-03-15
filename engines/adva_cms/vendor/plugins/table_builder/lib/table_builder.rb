require 'action_view/helpers/tag_helper'

require 'table_builder/tag'
require 'table_builder/cell'
require 'table_builder/row'
require 'table_builder/rows'
require 'table_builder/body'
require 'table_builder/head'
require 'table_builder/foot'
require 'table_builder/column'
require 'table_builder/table'

module TableBuilder
  mattr_accessor :options
  self.options = { 
    :alternate_rows => true,
    :i18n_scope => nil
  }

  def table_for(collection = [], options = {}, &block)
    concat Table.new(self, collection, options, &block).render
  end
end


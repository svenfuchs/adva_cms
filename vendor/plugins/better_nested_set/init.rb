# better_nested_set
# (c) 2005 Jean-Christophe Michel 
# MIT licence
#
require 'better_nested_set'
require 'better_nested_set_helper'

ActiveRecord::Base.class_eval do
  include SymetrieCom::Acts::NestedSet
end
ActionView::Base.send :include, SymetrieCom::Acts::BetterNestedSetHelper if defined? ActionView 
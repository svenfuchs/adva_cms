class Node < ActiveRecord::Base
end

class FooNode < Node
  acts_as_nested_set :scope => :foo_id
end
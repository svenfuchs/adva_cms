ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define(:version => 1) do
  create_table "nodes", :force => true do |t|
    t.string  :name
    t.string  :type
    t.integer :lft
    t.integer :rgt
    t.integer :foo_id
    t.integer :parent_id
  end
end

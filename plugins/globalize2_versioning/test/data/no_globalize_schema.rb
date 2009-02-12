# This schema creates tables without columns for the translated fields
ActiveRecord::Schema.define do
  create_table :blogs, :force => true do |t|
    t.string      :description
  end

  create_table :posts, :force => true do |t|
    t.references  :blog
  end

  create_table :sections, :force => true do |t|
  end
  
  create_table :contents, :force => true do |t|
    t.string      :type
  end
end
  

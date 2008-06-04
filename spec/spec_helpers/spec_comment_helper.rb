class Commentable < AbstractActiveRecord
  acts_as_commentable

  attr_accessor :title
  attr_accessor :section
  attr_accessor :section_id
  attr_accessor :comment_filter
  
  def after_initialize
    @comment_filter = 'textile'
  end
end

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 0) do
  create_table :commentables, :force => true do |t|
    t.integer :comments_count
  end
end


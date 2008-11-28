class CreateSectionsTable < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string      :type
      t.references  :site
      t.integer     :parent_id
      t.integer     :lft, :null => false, :default => 0
      t.integer     :rgt, :null => false, :default => 0
      t.string      :path
      t.string      :permalink
      t.string      :title
      t.string      :layout
      t.string      :template
      t.text        :options
      t.integer     :contents_count
	    t.integer     :comment_age
	    t.string      :content_filter
      t.text        :permissions
    end
  end

  def self.down
    drop_table :sections
  end
end

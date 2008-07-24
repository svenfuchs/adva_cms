class AddTopicAuthor < ActiveRecord::Migration
  def self.up
    add_column :topics, :author_id, :integer
    add_column :topics, :author_type, :string
  end

  def self.down
    remove_column :topics, :author_id
    remove_column :topics, :author_type
  end
end

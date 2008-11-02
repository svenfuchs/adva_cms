class AddSpamInfoToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :spaminess, :text
  end

  def self.down
    remove_column :comments, :spaminess
  end
end

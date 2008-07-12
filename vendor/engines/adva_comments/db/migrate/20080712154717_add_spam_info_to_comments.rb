class AddSpamInfoToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :spam_info, :text
  end

  def self.down
    remove_column :comments, :spam_info
  end
end

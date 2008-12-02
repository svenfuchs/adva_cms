class CreateConversations < ActiveRecord::Migration
  def self.up
     create_table :conversations, :force => true do |t|
       t.integer :messages_count, :default => 0
       t.timestamps
    end
  end

  def self.down
    drop_table :conversations
  end
end

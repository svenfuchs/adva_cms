class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages, :force => true do |t|
	    t.string      "subject",        :default => "", :null => false
    	t.text        "body",           :default => "", :null => false
	
    	t.integer     "sender_id"
    	t.integer     "recipient_id"
    	t.integer     "parent_id"
    	t.integer     "conversation_id"
	    
    	t.timestamps
    	t.datetime    "read_at"
    	t.datetime    "deleted_at_sender"
    	t.datetime    "deleted_at_recipient"
    end
  end

  def self.down
    drop_table :messages
  end
end

class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions, :force => true do |t|
      t.integer :user_id, :null => false
      t.integer :subscribable_id, :null => false
      t.string  :subscribable_type, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end

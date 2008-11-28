class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions, :force => true do |t|
      t.integer :subscribable_id
      t.string  :subscribable_type
      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end

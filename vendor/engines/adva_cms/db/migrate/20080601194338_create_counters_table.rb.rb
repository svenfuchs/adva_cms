class CreateCountersTable < ActiveRecord::Migration
  def self.up
    create_table :counters, :force => true do |t|
      t.references :owner, :polymorphic => true
      t.string     :name, :limit => 25
      t.integer    :count, :default => 0
    end    
  end

  def self.down
    drop_table :counters
  end
end

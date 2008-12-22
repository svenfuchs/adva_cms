class CreateEmail < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.string :from
      t.string :to
      t.integer :last_send_attempt, :default => 0
      t.text :mail
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :emails
  end
end

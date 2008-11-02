class SpamReportsTable < ActiveRecord::Migration
  def self.up
    create_table :spam_reports do |t|
      t.references :subject, :polymorphic => true
      t.string :engine
      t.float :spaminess
      t.text :data
    end
  end

  def self.down
    drop_table :spam_reports
  end
end

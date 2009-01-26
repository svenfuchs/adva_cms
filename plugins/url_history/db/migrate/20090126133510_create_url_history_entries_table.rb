class CreateUrlHistoryEntriesTable < ActiveRecord::Migration
  def self.up
    create_table :url_history_entries, :force => true do |t|
      t.string     :url
      t.text       :params
      t.references :resource, :polymorphic => true
    end
  end

  def self.down
    drop_table :url_history_entries
  end
end

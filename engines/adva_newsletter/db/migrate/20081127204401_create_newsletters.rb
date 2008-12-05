class CreateNewsletters < ActiveRecord::Migration
  def self.up
    create_table :newsletters, :force => true do |t|
      t.references :site
      t.integer    :subscriptions_count, :default => 0
      t.integer    :issues_count, :default => 0
      
      t.string     :title, :null => false
      t.text       :desc

      t.timestamps
    end
  end

  def self.down
    drop_table :newsletters
  end
end

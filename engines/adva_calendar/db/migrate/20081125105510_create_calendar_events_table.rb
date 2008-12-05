class CreateCalendarEventsTable < ActiveRecord::Migration
  def self.up
    create_table :calendar_events, :force => true do |t|
      t.string     :title, :null => false
      t.string     :permalink
      
      t.datetime   :startdate, :null => false
      t.datetime   :enddate
      t.datetime   :published_at
      
      t.string     :host
      t.text       :body
      t.text       :body_html
      t.string     :filter
      
      t.integer    :parent_id
      
      t.references :section
      t.references :user
      
      t.timestamps
    end
    add_index :calendar_events, :permalink, :unique => true
  end

  def self.down
    drop_table :calendar_events
  end
end
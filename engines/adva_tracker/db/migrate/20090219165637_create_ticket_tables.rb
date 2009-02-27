class CreateTicketTables < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.references :section
      t.references :site
      t.string     :title
      t.string     :desc
      t.integer    :milestones_count, :default => 0
      t.timestamps
    end
    
    create_table :tickets do |t|
      t.references :user
      t.string     :title
      t.text       :body
      t.string     :state
      t.string     :states
      t.integer    :assignments_count, :default => 0
      t.timestamps
    end
    
    create_table :assignments do |t|
      t.references :ticket
      t.references :user
      t.timestamps
    end
    
    create_table :milestones do |t|
      t.references :project
      t.string     :title
      t.string     :desc
      t.timestamps
    end
  end

  def self.down
    drop_table :projects
    drop_table :tickets
    drop_table :assignments
    drop_table :milestones
  end
end

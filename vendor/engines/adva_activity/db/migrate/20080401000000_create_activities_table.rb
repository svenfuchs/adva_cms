class CreateActivitiesTable < ActiveRecord::Migration
  def self.up
    create_table :activities, :force => true do |t|
      t.references :site
      t.references :section

      t.references :author, :polymorphic => true
      t.string     :author_name, :limit => 40
      t.string     :author_email, :limit => 40
      t.string     :author_homepage

      t.string     :actions
      t.integer    :object_id
      t.string     :object_type, :limit => 15
      t.text       :object_attributes
      t.datetime   :created_at, :null => false
    end
  end

  def self.down
    drop_table :activities
  end
end

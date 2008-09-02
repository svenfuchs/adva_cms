class CreateCommentsTable < ActiveRecord::Migration
  def self.up
    create_table :comments, :force => true do |t|
      t.references :site
      t.references :section
      # t.references :topic # TODO can we use the commentable reference as the topic reference?
      t.references :commentable, :polymorphic => true
      t.references :author, :polymorphic => true
      t.string     :author_name, :limit => 40
      t.string     :author_email, :limit => 40
      t.string     :author_homepage
      t.text       :body
      t.text       :body_html
      t.integer    :approved, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
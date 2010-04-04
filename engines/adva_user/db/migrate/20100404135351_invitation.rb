class Invitation < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.string :email
      t.string :token
      t.integer :site_id
      t.text :roles
      t.timestamps
    end
    
  end

  def self.down
    drop_table :invitations
  end
end

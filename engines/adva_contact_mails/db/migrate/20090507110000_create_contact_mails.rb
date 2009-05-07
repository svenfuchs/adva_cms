class CreateContactMails < ActiveRecord::Migration
  def self.up
    create_table :contact_mails, :force => true do |t|
      t.references :site
      
      t.string     :subject
      t.string     :body
      t.string     :email, :limit => 40
      t.timestamps
    end
  end

  def self.down
    drop_table :contact_mails
  end
end
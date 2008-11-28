class CreateNewsletters < ActiveRecord::Migration
  def self.up
    create_table :newsletters, :force => true do |t|
      t.references :site
      
      t.string     :title
      t.text       :body

      t.timestamps
    end
  end

  def self.down
    drop_table :newsletters
  end
end

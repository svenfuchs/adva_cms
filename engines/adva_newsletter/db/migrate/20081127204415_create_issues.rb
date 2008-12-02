class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues, :force => true do |t|
      t.references :newsletter

      t.string     :title, :null => false
      t.text       :body,  :null => false
      t.datetime   :due_at
      
      t.timestamps
    end
  end

  def self.down
  end
end

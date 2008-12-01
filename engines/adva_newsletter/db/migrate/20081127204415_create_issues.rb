class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues, :force => true do |t|
      t.references :newsletter

      t.datetime   :due_at, :null => false
      
      t.timestamps
    end
  end

  def self.down
  end
end

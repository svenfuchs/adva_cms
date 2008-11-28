class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues, :force => true do |t|
      t.references :newsletter
      
      t.timestamps
    end
  end

  def self.down
  end
end

class CreateTimestamped < ActiveRecord::Migration
  def self.up
    create_table 'timestamped' do |t|
    end
  end

  def self.down
    drop_table 'timestamped'
  end
end

class CreateOtherTimestamped < ActiveRecord::Migration
  def self.up
    create_table 'other_timestamped' do |t|
    end
  end

  def self.down
    drop_table 'other_timestamped'
  end
end

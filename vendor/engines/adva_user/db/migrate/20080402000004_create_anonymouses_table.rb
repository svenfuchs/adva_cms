class CreateAnonymousesTable < ActiveRecord::Migration
  def self.up
    create_table :anonymouses do |t|
      t.string     :name,             :limit => 40
      t.string     :email,            :limit => 100
      t.string     :homepage

      t.string     :ip
      t.string     :agent
      t.string     :referer

      t.string     :token_key,        :limit => 40
      t.datetime   :token_expiration
      
      t.timestamps
    end
  end

  def self.down
    drop_table :request_infos
  end
end

class CreateUsersTable < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string     :first_name,       :limit => 40
      t.string     :last_name,        :limit => 40
      t.string     :email,            :limit => 100
      t.string     :homepage
      t.string     :about
      t.string     :signature
      
      t.string     :login,            :limit => 40
      t.string     :password_hash,    :limit => 40
      t.string     :password_salt,    :limit => 40
      
      t.string     :remember_me,      :limit => 40
      t.string     :token_key,        :limit => 40
      t.datetime   :token_expiration
      
      t.timestamps
      t.datetime   :verified_at
      t.datetime   :deleted_at
    end
  end

  def self.down
    drop_table :users
  end
end

ActiveRecord::Schema.define(:version => 0) do
  create_table :users, :force => true do |t|
    t.column :name, :string, :null => false
    t.column :password_hash, :string, :length => 40
    t.column :password_salt, :string, :length => 40
    t.column :token_key, :string, :length => 40
    t.column :token_expiration, :datetime
    t.column :remember_me, :string, :length => 40
  end
end
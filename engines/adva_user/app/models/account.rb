class Account < ActiveRecord::Base
  has_many :users

  def members
    
  end
end
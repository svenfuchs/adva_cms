class Monkey < ActiveRecord::Base
  attr_accessor :unique, :counter, :number
    
  belongs_to :pirate
  validates_presence_of :name
end

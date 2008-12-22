class Email < ActiveRecord::Base
  validates_presence_of :from, :to, :mail
end

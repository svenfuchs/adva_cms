class ContactMail < ActiveRecord::Base
  belongs_to :site
  
  validates_presence_of :subject, :body
end
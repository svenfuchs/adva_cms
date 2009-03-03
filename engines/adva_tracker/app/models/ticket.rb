class Ticket < ActiveRecord::Base
  attr_accessible :title, :body, :filter, :ticketable_type, :ticketable_id
  validates_presence_of :title, :body, :ticketable_type, :ticketable_id
  
  filtered_column :body
  filters_attributes :except => [:body, :body_html]
end

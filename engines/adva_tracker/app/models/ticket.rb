class Ticket < ActiveRecord::Base
  # When attaching Ticket to your parent model, 
  # don't forget to add ticekts_count field to your model:
  # t.integer :tickets_count, :default => 0
  belongs_to :ticketable, :polymorphic => true, :counter_cache => true
  belongs_to_author

  belongs_to :section
  acts_as_role_context :parent => Section

  attr_accessible :title, :body, :filter,
                  :ticketable_type, :ticketable_id,
                  :author_id, :author

  validates_presence_of :title, :body,
                        :ticketable_type, :ticketable_id,
                        :author_id, :author

  filtered_column :body
  filters_attributes :except => [:body, :body_html]
end

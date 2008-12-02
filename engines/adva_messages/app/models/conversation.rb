class Conversation < ActiveRecord::Base
  has_many :messages, :order => :created_at
  
  def mark_messages_as_read
    messages.each { |m| m.mark_as_read }
  end
end
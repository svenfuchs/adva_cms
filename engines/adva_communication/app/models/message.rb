class Message < Communication
  belongs_to :sender,    :class_name => "User", :foreign_key => "sender_id"
  belongs_to :recipient, :class_name => "User", :foreign_key => "recipient_id"
  
  def is_reply?
    !parent_id.nil?
  end
  
  def mark_as_read
    update_attribute(:read_at, Time.now)
  end
  
  def mark_as_deleted(object)
    if sender?(object) && recipient(object)
      update_attributes(:deleted_at_sender => Time.now,
                        :deleted_at_recipient => Time.now)
    elsif sender?(object)
      update_attribute(:deleted_at_sender, Time.now)
    elsif recipient?(object)
      update_attribute(:deleted_at_recipient, Time.now)
    else
      return false
    end
  end
  
  def sender?(object)
    sender_id == object.id
  end
  
  def recipient?(object)
    recipient_id == object.id
  end
end
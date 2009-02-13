class Message < ActiveRecord::Base
  belongs_to :sender,    :class_name => "User",    :foreign_key => "sender_id"
  belongs_to :recipient, :class_name => "User",    :foreign_key => "recipient_id"
  belongs_to :conversation, :counter_cache => true
  
  before_create :assign_to_conversation
  
  validates_presence_of :subject, :body, :recipient, :sender
  
  def self.reply_to(message)
    options = {}
    options[:recipient_id] = message.sender_id
    options[:subject]      = message.reply_subject
    options[:parent_id]    = message.id
    Message.new(options)
  end
  
  def is_reply?
    !parent_id.nil?
  end
  
  def deliver
    # FIXME implement more elegant way to do this
    return self.save unless self.recipient.respond_to?(:banships)
    
    if Banship.exists?(self.recipient, self.sender)
      # FIXME This stuff needs revisiting!
      #       Banning other user basically just means that
      #       we filter his inbox so that he never sees the message.
      #       But what happens when we implement trashbox?
      self.read_at              = Time.now
      self.deleted_at_recipient = Time.now
      self.save
    else
      self.save
    end
  end
  
  def mark_as_read
    update_attribute(:read_at, Time.now)
  end
  
  def mark_as_deleted(object)
    if sender?(object) && recipient?(object)
      update_attributes(:deleted_at_sender    => Time.now,
                        :deleted_at_recipient => Time.now)
    elsif sender?(object)
      update_attribute(:deleted_at_sender, Time.now)
    elsif recipient?(object)
      update_attribute(:deleted_at_recipient, Time.now)
    else
      return false
    end
  end
  
  def parent
    parent_id.nil? ? nil : Message.find(parent_id)
  end
    
  def reply_subject
    subject[0..2] == 'Re:' ? subject : 'Re: ' + subject
  end

  def recipient?(object)
    recipient_id == object.id
  end
    
  def sender?(object)
    sender_id == object.id
  end
    
  protected
    def assign_to_conversation
      self.conversation = parent.nil? ? Conversation.create : parent.conversation
    end
end
class DeletedNewsletter < BaseNewsletter
  validates_presence_of :deleted_at

  def restore
    self.type = "Newsletter"
    self.deleted_at = nil
    self.save(false)
    return self
  end
end

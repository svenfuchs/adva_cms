class DeletedIssue < BaseIssue
  belongs_to :newsletter

  validates_presence_of :deleted_at
  
  def restore
    self.type = "Issue"
    self.deleted_at = nil
    if self.save(false)
      Newsletter.update_counters self.newsletter_id, :issues_count => +1
    end
    return self
  end
end

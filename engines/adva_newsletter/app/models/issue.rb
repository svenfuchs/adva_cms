class Issue < BaseIssue
  belongs_to :newsletter, :counter_cache => true

  def destroy
    self.deleted_at = Time.now.utc
    self.type = "DeletedIssue"
    if self.save
      Newsletter.update_counters self.newsletter_id, :issues_count => -1
    end
    return self
  end
end

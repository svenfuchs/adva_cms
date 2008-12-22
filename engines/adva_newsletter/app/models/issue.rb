class Issue < BaseIssue
  belongs_to :newsletter, :counter_cache => true
  validates_presence_of :newsletter_id

  def deliver(options = {})
    options.assert_valid_keys(:later,:to)
    @test_user, deliver_time = options[:to], options[:later]
    
    if @test_user.nil?
      deliver_time.nil? ? deliver_all_now : 'deliver all later'
    else
      deliver_time.nil? ? deliver_to_now : 'deliver later to'
    end
  end

  def destroy
    self.deleted_at = Time.now.utc
    self.type = "DeletedIssue"
    if self.save
      Newsletter.update_counters self.newsletter_id, :issues_count => -1
    end
    return self
  end
  
private
  def deliver_to_now
    NewsletterMailer.deliver_issue(self,@test_user)
    self.published_at = Time.now.utc
    self.save
  end
  
  #TODO move this logic to correct place
  def deliver_all_now
    self.newsletter.users.each do |user|
      @issue = NewsletterMailer.create_issue(self,user)
      @email = Email.create(:from => self.newsletter.site.email, :to => user.email, :mail => @issue.encoded)
    end
    self.published_at = Time.now.utc
    self.save
  end
end

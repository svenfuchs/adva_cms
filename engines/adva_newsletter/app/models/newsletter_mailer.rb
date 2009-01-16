class NewsletterMailer < ActionMailer::Base
  def issue(local_issue,user)
    recipients  user.email
    from        local_issue.email
    subject     "[#{local_issue.newsletter.site.name}] #{local_issue.title}"
    body        local_issue.body
  end 
end

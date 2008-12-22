class NewsletterMailer < ActionMailer::Base
  def issue(issue,user)
    recipients  user.email
    from        "#{issue.newsletter.site.name} <#{issue.newsletter.site.email}>"
    subject     "[#{issue.newsletter.site.name}] " + issue.title
    body        issue.body
  end 
end

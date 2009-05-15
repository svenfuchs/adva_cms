class Adva::NewsletterMailer < ActionMailer::Base
  def issue(issue,user)
    recipients  user.email
    from        issue.newsletter.default_email
    subject     "[#{issue.newsletter.default_name}] #{issue.title}"
    body        issue.body_html
    headers     Adva::Config.email_header
  end 
end

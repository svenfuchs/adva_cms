class Adva::NewsletterMailer < ActionMailer::Base
  def issue(issue,user)
    recipients         user.email
    from               issue.newsletter.email
    subject           "[#{issue.newsletter.name}] #{issue.title}"
    content_type      "multipart/related"
    headers           Adva::Config.email_header

    part :content_type => 'multipart/alternative' do |p|
      
      #TODO implement plain text as well
      # p.part :content_type => 'text/plain',
             # :body => issue.body_plain

      p.part :content_type => 'text/html',
             :transfer_encoding => 'base64',
             :body => render_message("issue", :body => issue.body_mail)

      #TODO there must be better way? Without this hack, TMail will not honor custom "Content-ID".
      TMail::HeaderField::FNAME_TO_CLASS.delete 'content-id'

      issue.images.each do |image|
        p.attachment :content_type      => image.content_type,
                     :filename          => image.filename,  #FIXME when inline then filename is not honored by ActionMailer 2.3.2
                     :disposition       => 'inline',
                     :transfer_encoding => 'base64',
                     :body              => image.file,
                     :headers           => {"Content-ID" => image.cid}
      end
    end
  end 
end

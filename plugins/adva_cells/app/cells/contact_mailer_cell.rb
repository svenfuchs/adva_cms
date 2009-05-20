class ContactMailerCell < BaseCell
  tracks_cache_references :recent, :track => ['@section', '@articles']
  
  has_state :recent
  
  helper :content, :resource
  
  def mailer_form
    @recipients = @opts["recipients"]
    @subject    = @opts["subject"]
    
    nil
  end
end
class SiteFormBuilder < ExtensibleFormBuilder
  after(:site, :default_fields) do |f|
    render :partial => 'admin/sites/email_notifications', :locals => { :f => f }
  end
end
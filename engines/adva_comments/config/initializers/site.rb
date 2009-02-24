class SiteFormBuilder < ExtensibleFormBuilder
  after(:site, :default_fields) do |f|
    render :partial => 'admin/sites/comments_settings', :locals => { :f => f }
  end
end
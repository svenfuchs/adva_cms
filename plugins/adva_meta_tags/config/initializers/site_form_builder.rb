class SiteFormBuilder < ExtensibleFormBuilder
  after(:site, :default_fields) do |f|
    render :partial => 'admin/sites/meta_tags', :locals => { :f => f }
  end
end

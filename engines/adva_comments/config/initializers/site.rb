class SiteFormBuilder < ExtensibleFormBuilder
  after(:site, :default_fields) do |f|
    render :partial => 'admin/sites/comments_settings', :locals => { :f => f }
  end
end

ActionController::Dispatcher.to_prepare do
  Site.has_many_comments
end
ActionController::Dispatcher.to_prepare do
  require_dependency 'site'

  class Site
    cattr_reader :meta_fields
    @@meta_fields = %w(keywords description author copyright geourl)
  end
end

class SiteFormBuilder < ExtensibleFormBuilder
  after(:site, :default_fields) do |f|
    render :partial => 'admin/sites/meta_tags', :locals => { :f => f }
  end
end

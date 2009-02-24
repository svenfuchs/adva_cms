class SiteFormBuilder < ExtensibleFormBuilder
  after(:site, :default_fields) do |f|
    <<-html
      <h2>Google Analytics</h2>
      <fieldset class="clearfix">
        #{ f.text_field :google_analytics_tracking_code, 
                        :label => 'Google Analytics Tracking Code', 
                        :hint => :'adva.tracking.hints.tracking_code' }
      </fieldset>
    html
  end
end
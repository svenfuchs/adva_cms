class SiteFormBuilder < ExtensibleFormBuilder
  after(:site, :default_fields) do |f|
    <<-html
      <h2>Google Analytics</h2>
      <fieldset class="clearfix">
        <div class="col">
        #{ f.text_field :google_analytics_tracking_code, 
                        :label => 'Google Analytics Tracking Code', 
                        :hint => :'adva.tracking.hints.tracking_code'}
        </div>
      </fieldset>
    html
  end
end
ActionController::Dispatcher.to_prepare do
  Site.class_eval do
    def tracking_enabled?
      google_analytics_tracking_code.present?
    end
    alias :has_tracking_enabled? :tracking_enabled?
  end
end

class SiteFormBuilder < ExtensibleFormBuilder
  after(:site, :default_fields) do |f|
    <<-html
      <h2>Google Analytics</h2>
      <fieldset class="clearfix">
        #{ f.text_field :google_analytics_tracking_code, 
                        :label => 'Google Analytics Tracking Code', 
                        :hint => :'adva.tracking.hints.tracking_code'}
      </fieldset>
    html
  end
end

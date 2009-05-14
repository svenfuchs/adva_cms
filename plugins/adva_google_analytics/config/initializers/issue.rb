if Rails.plugin?(:adva_newsletter)
  ActionController::Dispatcher.to_prepare do
    Adva::Issue.class_eval do
      attr_accessible :title, :body, :filter, :draft, :deliver_at, :tracking_source, :track, :tracking_campaign
  
      def has_tracking_enabled?
        track? && !(newsletter.site.google_analytics_tracking_code.blank? || tracking_campaign.blank? || tracking_source.blank?)
      end
    
      def body_html
        has_tracking_enabled? ? track_links(attributes["body_html"]) : attributes["body_html"]
      end

      private

        def track_links(content)
          content.gsub(/<a(.*)href="#{Regexp.escape("http://#{newsletter.site.host}")}(.*)"(.*)>/) do |s|
            m = [$1, $2, $3] # why do I need this?
            returning %(<a#{m[0]}href="http://#{newsletter.site.host}) do |s|
              s << ("#{m[1]}#{m[1].include?("?") ? "&" : "?"}utm_medium=newsletter&utm_campaign=#{URI.escape(tracking_campaign)}&utm_source=#{URI.escape(tracking_source)}") if m[1]
              s << %("#{m[2]}>)
            end
          end
        end
    end
  end
  
  class IssueFormBuilder < ExtensibleFormBuilder
    after(:issue, :optional_settings) do |f|
      render :partial => 'admin/issues/tracking'
    end
  end
end

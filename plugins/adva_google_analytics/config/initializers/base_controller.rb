ActionController::Dispatcher.to_prepare do
  BaseController.class_eval do
    content_for :foot, :call_google_analytics, :only => { :format => :html } do
      if controller.site.try(:tracking_enabled?)
        <<-html
          <script type="text/javascript">
            var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
            document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
          </script>
          <script type="text/javascript">
            var pageTracker = _gat._getTracker("#{@site.google_analytics_tracking_code}");
            pageTracker._trackPageview();
          </script>
        html
      end
    end
  end
end

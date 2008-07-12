module Shield
  module Spam
    class None < Guard
      Site.register_spam_detection_engine "None", self

      class << self
        def settings_template(site)
          load_template(File.join(File.dirname(__FILE__), "null_settings.html.erb")).render(:site => site, :options => site.spam_engine_options)
        end
      end

      def null?
        true
      end

      def statistics_template
        ""
      end

      def announce_article(permalink_url, article)
      end

      def ham?(permalink_url, comment, options={})
        true
      end

      def mark_as_ham(permalink_url, comment)
      end

      def mark_as_spam(permalink_url, comment)
      end

      def valid?
        true
      end

      def valid_key?
        true
      end
    end
  end
end

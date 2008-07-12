module SpamEngine
  class None < Base
    class << self
      def settings_template(site)
        load_template(File.join(File.dirname(__FILE__), "null_settings.html.erb")).render(:site => site, :options => site.spam_engine_options)
      end
    end

    def statistics_template
      ""
    end

    def announce_article(permalink_url, article)
    end

    def check_comment(permalink_url, comment, options={})
      {:spam => false}
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

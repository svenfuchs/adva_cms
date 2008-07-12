module Shield
  module Spam
    class Akismet < Guard
      Site.register_spam_detection_engine "Akismet", self

      class << self
        def settings_template(site)
          load_template(File.join(File.dirname(__FILE__), "akismet_settings.html.erb")).render(:site => site, :options => site.spam_engine_options)
        end
      end

      def statistics_template
        "<p>The Akismet API does not extract statistics about it's performance.</p>"
      end

      # Akismet doesn't care about real articles.
      def announce_article(permalink_url, article)
      end

      def ham?(permalink_url, comment, options={})
        check_valid!
        !akismet.comment_check(comment_spam_options(permalink_url, comment))
      end

      def mark_as_ham(permalink_url, comment)
        check_valid!
        akismet.submit_ham(comment_spam_options(permalink_url, comment))
      end

      def mark_as_spam(permalink_url, comment)
        check_valid!
        akismet.submit_spam(comment_spam_options(permalink_url, comment))
      end

      def valid?
        [:akismet_key, :akismet_url].all? { |attr| !options[attr].blank? }
      end

      def valid_key?
        self.valid? && akismet.verified?
      end

      def errors
        returning([]) do |es|
          es << "The Akismet key is missing" if options[:akismet_key].blank?
          es << "The Akismet url is missing" if options[:akismet_url].blank?
          es << "The Akismet API denied the key" unless akismet.verified?
        end
      end

      protected
      def akismet
        @akismet ||= Viking.connect("akismet", :api_key => options[:akismet_key], :blog => options[:akismet_url])
      end

      def comment_spam_options(permalink_url, comment)
        { :user_ip              => comment.author_ip, 
          :user_agent           => comment.user_agent, 
          :referrer             => comment.referrer,
          :permalink            => permalink_url, 
          :comment_author       => comment.author, 
          :comment_author_email => comment.author_email, 
          :comment_author_url   => comment.author_url, 
          :comment_content      => comment.body }
      end

      def check_valid!
        raise SpamGuardNotConfigured unless self.valid?
      end
    end
  end
end

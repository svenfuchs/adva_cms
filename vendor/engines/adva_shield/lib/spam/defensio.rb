module Shield
  module Spam
    class Defensio < Guard
      Site.register_spam_detection_engine "Defensio", self

      class << self
        def settings_template(site)
          load_template(File.join(File.dirname(__FILE__), "defensio_settings.html.erb")).render(:site => site, :options => site.spam_engine_options)
        end
      end

      def valid?
        [:defensio_url, :defensio_key].all? {|key| !options[key].blank?}
      end

      def valid_key?
        self.validate_key
      end

      class Stats
        def initialize(response)
          @response = response
        end

        def spam
          @response[:spam]
        end

        def ham
          @response[:ham]
        end

        def accuracy
          @response[:accuracy]
        end

        def false_negatives
          @response[:"false-negatives"]
        end

        def false_positives
          @response[:"false-positives"]
        end
      end

      def statistics_template
        stats = Stats.new(defensio.stats)
        return self.class.load_template(File.join(File.dirname(__FILE__), "defensio_statistics.html.erb")).render(:site => site, :options => site.spam_engine_options, :statistics => stats) if valid_key?
        return ""
      end

      def announce_article(permalink_url, article)
        response = defensio.check_article(
          :article_author => article.updater.login,
          :article_author_email => article.updater.email,
          :article_title => article.title,
          :article_content => article.body,
          :permalink => permalink_url
        )
      end

      def info(comment)
        return "" if comment.spam_engine_data.blank?
        signature = comment.spam_engine_data[:signature] || ""
        spaminess = comment.spam_engine_data[:spaminess] || 0
        spaminess *= 100
        "Spaminess: %.1f%%, Signature: %s" % [spaminess, signature]
      end

      def classes(comment)
        return "" if comment.spam_engine_data.blank?
        case (comment.spam_engine_data[:spaminess] || 0) * 100
        when 0
          "spam0"
        when 0...30
          "spam30"
        when 30...75
          "spam75"
        else
          "spam100"
        end
      end

      def ham?(permalink_url, comment, options={})
        response = defensio.check_comment(
          # Required parameters
          :user_ip => comment.author_ip,
          :article_date => comment.article.published_at.strftime("%Y/%m/%d"),
          :comment_author => comment.author,
          :comment_type => "comment",

          # Optional parameters
          :comment_content => comment.body,
          :comment_author_email => comment.author_email,
          :comment_author_url => comment.author_url,
          :permalink => permalink_url,
          :referrer => comment.referrer,
          :user_logged_in => options[:authenticated],
          :trusted_user => options[:authenticated]
        )

        comment.update_attribute(:spam_engine_data, {:signature => response[:signature], :spaminess => response[:spaminess].to_f})
        !response[:spam]
      end

      def mark_as_ham(permalink_url, comment)
        return if comment.spam_engine_data.blank? || comment.spam_engine_data[:signature].blank?
        defensio.mark_as_ham(:signatures => [comment.spam_engine_data[:signature]])
      end

      def mark_as_spam(permalink_url, comment)
        return if comment.spam_engine_data.blank? || comment.spam_engine_data[:signature].blank?
        defensio.mark_as_spam(:signatures => [comment.spam_engine_data[:signature]])
      end

      def sort_block
        lambda {|c| 1.0 - (c.spam_engine_data.blank? ? 0 : (c.spam_engine_data[:spaminess] || 0))}
      end

      def errors
        returning([]) do |es|
          es << "The Defensio key is missing" if options[:defensio_key].blank?
          es << "The Defensio url is missing" if options[:defensio_url].blank?

          unless self.valid_key?
            es << "The Defensio API says your key is invalid"
          end
        end
      end

      protected
      def defensio
        @defensio ||= Viking.connect("defensio", :api_key => options[:defensio_key], :blog => options[:defensio_url])
      end

      def validate_key
        @verified ||= defensio.verified?
      end
    end
  end
end

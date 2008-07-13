module SpamEngine
  class Akismet < Base
    SpamEngine.register self

    # Akismet doesn't care about real articles.
    def announce_article(permalink_url, article)
    end

    def check_comment(permalink_url, comment, options={})
      check_valid!
      {:spam => !akismet.check_comment(comment_spam_options(permalink_url, comment))}
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

    protected
    
      def akismet
        @akismet ||= Viking.connect("akismet", :api_key => options[:akismet_key], :blog => options[:akismet_url])
      end

      def comment_spam_options(permalink_url, comment)
        { :permalink            => permalink_url, 
          :user_ip              => comment.author_ip, 
          :user_agent           => comment.author_agent, 
          :referrer             => comment.author_referer,
          :comment_author       => comment.author_name, 
          :comment_author_email => comment.author_email, 
          :comment_author_url   => comment.author_homepage, 
          :comment_content      => comment.body }
      end

      def check_valid!
        raise NotConfigured unless self.valid?
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
  end
end

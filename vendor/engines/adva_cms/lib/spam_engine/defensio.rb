module SpamEngine
  class Defensio < Base
    SpamEngine.register self

    def valid?
      [:defensio_url, :defensio_key].all? {|key| !options[key].blank?}
    end

    def valid_key?
      self.validate_key
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

    def check_comment(permalink_url, comment, options = {})
      response = defensio.check_comment(comment_spam_options(permalink_url, comment))
      response ? response : {}
    end

    def mark_as_ham(permalink_url, comment)
      return if comment.spam_info[:signature].blank?
      defensio.mark_as_ham(:signatures => [comment.spam_info[:signature]])
    end

    def mark_as_spam(permalink_url, comment)
      return if comment.spam_info[:signature].blank?
      defensio.mark_as_spam(:signatures => [comment.spam_info[:signature]])
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
    
    def comment_spam_options(permalink_url, comment)
      { # Required parameters
        :user_ip => comment.author_ip,
        :article_date => comment.commentable.published_at,
        :comment_author => comment.author_name,
        :comment_type => "comment",

        # Optional parameters
        :permalink => permalink_url,
        :comment_content => comment.body,
        :comment_author_email => comment.author_email,
        :comment_author_url => comment.author_homepage,
        :referrer => comment.author_referer,
        :user_logged_in => options[:authenticated],
        :trusted_user => options[:authenticated] }
    end

    def validate_key
      @verified ||= defensio.verified?
    end
  end
end

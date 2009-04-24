module SpamEngine
  module Filter
    class Defensio < Base
      def check_comment(comment, context = {})
        result = backend.check_comment(comment_options(comment, context))
        spaminess = result[:spam] ? 100 : 0 # TODO we might want to use the real spaminess returned
        comment.spam_reports << SpamReport.new(:engine => name, :spaminess => spaminess, :data => result)
      end

      def mark_as_ham(comment, context = {})
        # FIXME implement this!
      end

      def mark_as_spam(comment, context = {})
        # FIXME implement this!
      end

      protected

        def backend
          @backend ||= Viking.connect("defensio", :api_key => key, :blog => url)
        end

        def comment_options(comment, context)
        { # Required parameters
          :user_ip => comment.author_ip,
          :article_date => comment.commentable.published_at,
          :comment_author => comment.author_name,
          :comment_type => "comment",

          # Optional parameters
          :permalink => context[:permalink],
          :comment_content => comment.body,
          :comment_author_email => comment.author_email,
          :comment_author_url => comment.author_homepage,
          :referrer => comment.author_referer,
          :user_logged_in => context[:authenticated],
          :trusted_user => context[:authenticated] }
        end

        # def info(comment)
        #   return "" if comment.spam_info.blank?
        #   signature = comment.spam_info[:signature] || ""
        #   spaminess = comment.spam_info[:spaminess] || 0
        #   spaminess *= 100
        #   "Spaminess: %.1f%%, Signature: %s" % [spaminess, signature]
        # end
        #
        # def classes(comment)
        #   return "" if comment.spam_info.blank?
        #   case (comment.spam_info[:spaminess] || 0) * 100
        #   when 0
        #     "spam0"
        #   when 0...30
        #     "spam30"
        #   when 30...75
        #     "spam75"
        #   else
        #     "spam100"
        #   end
        # end
        #
        # def sort_block
        #   lambda {|c| 1.0 - (c.spam_info.blank? ? 0 : (c.spam_info[:spaminess] || 0))}
        # end
        #
        # def errors
        #   returning([]) do |es|
        #     es << "The Defensio key is missing" if options[:defensio_key].blank?
        #     es << "The Defensio url is missing" if options[:defensio_url].blank?
        #
        #     unless self.valid_key?
        #       es << "The Defensio API says your key is invalid"
        #     end
        #   end
        # end
    end
  end
end
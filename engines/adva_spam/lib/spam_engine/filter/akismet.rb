module SpamEngine
  module Filter
    class Akismet < Base
      def check_comment(comment, context = {})
        is_ham = backend.check_comment(comment_options(comment, context))
        comment.spam_reports << SpamReport.new(:engine => name, :spaminess => (is_ham ? 0 : 100))
      end

      def mark_as_ham(comment, context = {})
        key && url
      end

      def mark_as_spam(comment, context = {})
        key && url
      end

      protected

        def backend
          @backend ||= Viking.connect("akismet", :api_key => key, :blog => url)
        end

        def comment_options(comment, context)
          { :permalink            => context[:permalink],
            :user_ip              => comment.author_ip,
            :user_agent           => comment.author_agent,
            :referrer             => comment.author_referer,
            :comment_author       => comment.author_name,
            :comment_author_email => comment.author_email,
            :comment_author_url   => comment.author_homepage,
            :comment_content      => comment.body }
        end
    end
  end
end
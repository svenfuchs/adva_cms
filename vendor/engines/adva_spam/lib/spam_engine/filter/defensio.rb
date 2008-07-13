module SpamEngine
  module Filter
    class Defensio < Base
      SpamEngine::Filter.register self
      
      def check_comment(comment, context = {})
        result = backend.check_comment(comment_options(comment, context))
        SpamReport.new(:engine => name, :spaminess => result[:spaminess], :data => result)
      end
      
      def mark_as_ham(comment, context = {})
        key && url
      end
      
      def mark_as_spam(comment, context = {})
        key && url
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
          :permalink => context[:url],
          :comment_content => comment.body,
          :comment_author_email => comment.author_email,
          :comment_author_url => comment.author_homepage,
          :referrer => comment.author_referer,
          :user_logged_in => context[:authenticated],
          :trusted_user => context[:authenticated] }
        end
    end    
  end  
end
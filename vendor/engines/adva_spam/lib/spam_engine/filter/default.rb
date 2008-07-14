module SpamEngine
  module Filter
    class Default < Base
      def check_comment(comment, context = {})
        spaminess = auto_approve?(context) ? 0 : 100
        comment.spam_reports << SpamReport.new(:engine => name, :spaminess => spaminess)
        spaminess != 0 # i.e. stop the filter chain if the comment was auto_approved
      end
      
      def mark_as_ham(comment, context = {})
        # nothing to do
      end
      
      def mark_as_spam(comment, context = {})
        # nothing to do
      end
      
      protected
      
        def auto_approve?(context)
          options[:auto_approve] == 'all' or 
          options[:auto_approve] == 'authenticated' && context[:authenticated]
        end
    end
  end  
end

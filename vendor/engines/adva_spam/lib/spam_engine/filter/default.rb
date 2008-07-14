module SpamEngine
  module Filter
    class Default < Base
      SpamEngine::Filter.register self
      
      def initialize(options = {})
        super options.reverse_merge(:always_ham => false, :authenticated_ham => false)
      end
    
      def check_comment(comment, context = {})
        spaminess = always_ham ? 0 : authenticated_ham && context[:authenticated] ? 0 : 100
        comment.spam_reports << SpamReport.new(:engine => name, :spaminess => spaminess)
      end
      
      def mark_as_ham(comment, context = {})
        # nothing to do
      end
      
      def mark_as_spam(comment, context = {})
        # nothing to do
      end
    end
  end  
end

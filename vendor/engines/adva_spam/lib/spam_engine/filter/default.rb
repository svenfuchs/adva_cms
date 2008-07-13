module SpamEngine
  module Filter
    class Default < Base
      SpamEngine::Filter.register self
    
      def check_comment(comment, context = {})
        spaminess = always_ham ? 0 : authenticated_ham ? 0 : 100
        SpamReport.new :engine => name, :spaminess => spaminess
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

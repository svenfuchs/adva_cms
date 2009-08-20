if Rails.plugin?(:adva_comments)
  ActionController::Dispatcher.to_prepare do
    Comment.class_eval do
      has_many :spam_reports, :as => :subject

      def spam_info
        read_attribute(:spam_info) || {}
      end

      def spam_threshold
        51 # TODO have a config option on site for this
      end

      def ham?
        spaminess.to_i < spam_threshold
      end

      def spam?
        spaminess.to_i >= spam_threshold
      end

      def check_approval(context = {})
        if section.respond_to?(:spam_engine)
          section.spam_engine.check_comment(self, context)
          self.spaminess = calculate_spaminess
          self.approved = ham?
          save!
        end
      end

      def calculate_spaminess
        sum = spam_reports(true).inject(0) { |sum, report| sum + report.spaminess }
        sum > 0 ? sum / spam_reports.count : 0
      end
    end
  end
end
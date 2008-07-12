module SpamEngine
  class Defensio < Base
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

    # def statistics_template
    #   stats = Stats.new(defensio.stats)
    #   return self.class.load_template(File.join(File.dirname(__FILE__), "defensio_statistics.html.erb")).render(:site => site, :options => site.spam_engine_options, :statistics => stats) if valid_key?
    #   return ""
    # end
  end
end
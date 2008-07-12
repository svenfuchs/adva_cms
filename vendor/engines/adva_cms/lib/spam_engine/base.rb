require 'spam_engine/exceptions'

module SpamEngine
  class Base
    attr_reader :options

    def initialize(options = {})
      @options = options || {}
    end
    
    def name
      self.class.name.demodulize
    end

    # The default sort order is the original order.
    def sort_block
      lambda {|c| 0}
    end

    # Returns a fully formed HTML fragment that renders statistics on this
    # engine's performance.
    def statistics_template
      raise SubclassResponsibilityError
    end

    # Returns a series of HTML classes that should be added to the comment's blockquote.
    def classes(comment)
      ""
    end

    # Announces a new article was created.
    def announce_article(permalink_url, article)
      raise SubclassResponsibilityError
    end

    # Determines if a single comment is either ham or spam.
    def ham?(permalink_url, comment, options={})
      raise SubclassResponsibilityError
    end
    
    def mark_spaminess(spaminess, permalink_url, comment)
      send "mark_as_#{spaminess}", permalink_url, comment
    end

    # Marks false positives as ham.
    def mark_as_ham(permalink_url, comment)
      raise SubclassResponsibilityError
    end

    # Marks false negatives as spam.
    def mark_as_spam(permalink_url, comment)
      raise SubclassResponsibilityError
    end

    # Returns information about the comment, to be shown right next
    # to the comment's author.
    def info(comment)
      ""
    end

    # Determines if the configuration is valid or not.
    def valid?
      raise SubclassResponsibilityError
    end

    # Contacts the remote service and checks to see if the key is valid.
    def valid_key?
      raise SubclassResponsibilityError
    end

    # Returns an Array of error messages explaining why this spam engine is in an invalid state.
    def errors
    end

    class << self
      # Returns a fully rendered HTML template from which the engine can extract options.
      def settings_template(site)
        ""
      end

      # Loads the named file as an ERB template.  Returns a Template.
      def load_template(full_path)
        Template.new(File.read(full_path))
      end
    end
  end
end

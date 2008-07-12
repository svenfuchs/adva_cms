module SpamEngine
  class None < Base
    SpamEngine.register self

    def statistics_template
      ""
    end

    def announce_article(permalink_url, article)
    end

    def check_comment(permalink_url, comment, options = {})
      {}
    end

    def mark_as_ham(permalink_url, comment)
    end

    def mark_as_spam(permalink_url, comment)
    end

    def valid?
      true
    end

    def valid_key?
      true
    end
  end
end

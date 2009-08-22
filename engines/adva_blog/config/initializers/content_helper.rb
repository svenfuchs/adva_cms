ActionController::Dispatcher.to_prepare do
  # FIXME shouldn't use alias_method_chain
  module ContentHelper
    def article_path_with_blog(section, article, options = {})
      if article.section.is_a?(Blog)
        blog_article_path(section, article.full_permalink.merge(options))
      else
        article_path_without_blog(section, article, options)
      end
    end
    alias_method_chain :article_path, :blog

    def article_url_with_blog(section, article, options = {})
      if article.section.is_a?(Blog)
        blog_article_url(section, article.full_permalink.merge(options))
      else
        article_url_without_blog(section, article, options)
      end
    end
    alias_method_chain :article_url, :blog
  end
end
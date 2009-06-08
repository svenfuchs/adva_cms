ActionController::Dispatcher.to_prepare do
  require_dependency 'article'

  class Article
    cattr_reader :meta_fields
    @@meta_fields = %w(keywords description author copyright geourl)
  end
end

class ArticleFormBuilder < ExtensibleFormBuilder
  after :article, :tab_options do |f|
    tab :meta_tags do |f|
      render :partial => 'admin/articles/meta_tags', :locals => { :f => f }
    end
  end
end

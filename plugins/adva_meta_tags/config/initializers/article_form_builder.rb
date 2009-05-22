class ArticleFormBuilder < ExtensibleFormBuilder
  after :article, :tab_options do |f|
    tab :meta_tags do |f|
      render :partial => 'admin/articles/meta_tags', :locals => { :f => f }
    end
  end
end

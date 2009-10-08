class ArticleFormBuilder < ExtensibleFormBuilder
  after(:article, :tab_options) do |f|
    f.tab :assets do 
      template = instance_variable_get(:@template) # ugh
      assets = { :latest => @site.assets.recent, :attached => @article.assets, :bucket => @site.assets.bucket(template.session[:bucket]) }
      render :partial => 'admin/assets/widget/widget', :locals => { :assets => assets }
    end
  end
end

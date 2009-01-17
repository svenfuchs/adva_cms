module BlogHelper
  def articles_title(*args)
    options = args.extract_options!
    category, tags, month = *args

    title = []
    title << t(:'adva.blog.titles.date', :date => l(month, :format => '%B %Y')) if month
    title << t(:'adva.blog.titles.about', :category => category.title) if category
    title << t(:'adva.blog.titles.tags', :tags => tags.to_sentence) if tags
    
    unless title.empty?
      title = t(:'adva.blog.titles.articles', :articles => title.join(', ')) 
      options[:format] ? options[:format] % title : title
    end
  end

  def archive_month(params = {})
    Time.local(params[:year], params[:month]) if params[:year]
  end
end
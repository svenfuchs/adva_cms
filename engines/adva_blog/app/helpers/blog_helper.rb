module BlogHelper
  def collection_title(category=nil, tags=nil)
    title = []
    'Articles ' + title.join(', ') unless title.empty?
    title << t( :'adva.blog.title.date', :date => l(archive_month, '%B %Y') ) if archive_month
    title << t( :'adva.blog.title.about', :category => category.title ) if category
    title << t( :'adva.blog.title.tags', :tags => tags.to_sentence ) if tags
    t( :'adva.blog.title.articles', :articles => title.join(', ') ) unless title.empty?
  end

  def archive_month
    Time.local(params[:year], params[:month]) if params[:year]
  end
end
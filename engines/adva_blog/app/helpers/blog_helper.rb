module BlogHelper
  def collection_title(category=nil, tags=nil)
    title = []
    'Articles ' + title.join(', ') unless title.empty?
    title << t( :'adva.blog.titles.date', :date => l(archive_month, :format => '%B %Y') ) if archive_month
    title << t( :'adva.blog.titles.about', :category => category.title ) if category
    title << t( :'adva.blog.titles.tags', :tags => tags.to_sentence ) if tags
    t( :'adva.blog.titles.articles', :articles => title.join(', ') ) unless title.empty?
  end

  def archive_month
    Time.local(params[:year], params[:month]) if params[:year]
  end
end
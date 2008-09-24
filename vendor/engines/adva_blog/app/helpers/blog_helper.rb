module BlogHelper
  def collection_title(category=nil, tags=nil)
    title = []
    title << "from #{archive_month.strftime('%B %Y')}" if archive_month
    title << "about #{category.title}" if category
    title << "tagged #{tags.to_sentence}" if tags
    'Articles ' + title.join(', ') unless title.empty?
  end

  def archive_month
    Time.local(params[:year], params[:month]) if params[:year]
  end
end
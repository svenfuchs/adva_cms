module PhotosHelper
  def collection_title(set=nil, tags=nil)
    title = []
    title << 'about '  + set.title if set
    title << 'tagged ' + tags.to_sentence if tags
    title.present? ? 'Photos ' + title.join(', ') : 'All photos'
  end

  def link_to_set(*args)
    text = args.shift if args.first.is_a? String
    set = args.pop
    section = args.pop || set.section
    link_to text || set.title, album_set_path(section, set)
  end

  def links_to_photo_sets(photo, key = nil)
    return if photo.sets.empty?
    links = photo.sets.map{|set| link_to_set photo.section, set }
    key ? ("#{key} " + links.join(', ')) : links
  end
end
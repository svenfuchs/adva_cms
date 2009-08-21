module WikiHelper
  class << self
    def included(base)
      ActionController::Routing::Routes.named_routes.instance_variable_get(:@module).class_eval do
        return if method_defined? :wikipage_path_with_home
        [:path, :url].each do |type|
          alias :"wikipage_#{type}_with_home" :"wikipage_#{type}"
          define_method :"wikipage_#{type}" do |*args|
            options = args.extract_options!
            wikipage, wiki = *args.reverse
            wiki ||= wikipage.section
            permalink = wikipage.respond_to?(:permalink) ? wikipage.permalink : wikipage
            wikipage_strip_home send(:"wikipage_#{type}_with_home", wiki, permalink, options)
          end
        end
        
        # alias :wikipage_url_with_home :wikipage_url
        # def wikipage_url(*args)
        #   options = args.extract_options!
        #   wikipage, wiki = *args.reverse
        #   wiki ||= wikipage.section
        #   wikipage_strip_home wikipage_url_with_home(wiki, wikipage.permalink, options)
        # end
  
        def wikipage_strip_home(path)
          path.sub!(%r(/wikipages/home(\.[^/]*)?$), '')
          path.present? ? path : '/'
        end
      end
    end
  end

  def wiki_content_path(content, options = {})
    wikipage_path *[content.section, content.permalink, options].compact
  end

  def wikify(str)
    redcloth = RedCloth.new(str)
    redcloth.gsub!(/\[\[(.*?)(\|[^\]]*)?\]\]/) { wikify_link($1, $2.to_s[1..-1]) }
    auto_link redcloth.to_html
  end

  def wikify_link(str, text=nil)
    permalink = str.to_url
    text ||= str
    options = {}
    options[:class] = "new_wiki_link" unless Wikipage.find_by_permalink(permalink)
    link_to text, wikipage_path(@section, permalink), options
  end

  def wiki_edit_links(wikipage, options = {})
    separator = options[:separator] || '' # || ' &middot; '

	  links = []
	  links << content_tag(:li, options[:prepend]) if options[:prepend]
	  links << content_tag(:li) do
	    link_to(t(:'adva.wiki_helper.wiki_edit_links.link_to_home'), wiki_path(@section))
    end unless wikipage.home?

	  if wikipage.version == wikipage.versions.last
	    links << authorized_tag(:li, :update, wikipage) do
	      link_to(t(:'adva.wiki_helper.wiki_edit_links.link_to_edit'), edit_wikipage_path(@section, wikipage.permalink))
      end
    end

    links << wiki_version_links(wikipage)
	  links << content_tag(:li, options[:append]) if options[:append]

    content_tag :ul, links * "\n", :class => 'links'
  end

  def wiki_version_links(wikipage)
    links = []

    if wikipage.versions.count > 1
      if wikipage.version > wikipage.versions.first
  	    links << content_tag(:li) do
  	      link_to t(:'adva.wiki_helper.wiki_version_links.link_to_previous_revision'),
  	              wikipage_rev_path(:section_id => @section.id, :id => wikipage.permalink, :version => (wikipage.version - 1))
	      end
      end
      if wikipage.version < wikipage.versions.last - 1
  	    links << content_tag(:li) do
  	      link_to t(:'adva.wiki_helper.wiki_version_links.link_to_next_revision'),
  	              wikipage_rev_path(:section_id => @section.id, :id => wikipage.permalink, :version => (wikipage.version + 1))
	      end
	    end
      if wikipage.version < wikipage.versions.last
  	    links << content_tag(:li) do
  	      link_to t(:'adva.wiki_helper.wiki_version_links.link_to_current_revision'),
  	              wikipage_path(wikipage)
	      end
      end
      if wikipage.version != wikipage.versions.last
	      links << authorized_tag(:li, :update, wikipage) do
	        link_to t(:'adva.wiki_helper.wiki_version_links.link_to_rollback'),
	                wikipage_path_with_home(@section, wikipage.permalink, :version => wikipage.version),
	                :confirm => t(:'adva.wiki_helper.wiki_version_links.confirm_rollback'), :method => :put
        end
      end
    end

    links
  end

  def wikipages_title(*args)
    options = args.extract_options!
    category, tags = *args

    title = []
    title << t(:'adva.wiki_helper.collection_title.category_title', :title => category.title) if category
    title << t(:'adva.wiki_helper.collection_title.tags_title', :title => tags.to_sentence) if tags

    title = title.present? ? t(:'adva.wiki_helper.collection_title.collect_pages') + title.join(', ') : t(:'adva.wiki_helper.collection_title.all_pages')
    options[:format] ? options[:format] % title : title
  end
end

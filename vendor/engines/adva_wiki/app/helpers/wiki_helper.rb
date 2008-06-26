module WikiHelper
  class << self
    def included(base)
      [ActionController::Base, ActionView::Base].each do |target|
        return if target.method_defined? :wikipage_path_with_home
        [:path, :url].each do |kind|
          target.class_eval <<-CODE        
            alias :wikipage_#{kind}_with_home :wikipage_#{kind}
            def wikipage_#{kind}(*args)
              returning wikipage_#{kind}_with_home(*args) do |url|
                url.sub! %r(/pages/home\\b), ''
              end
            end
          CODE
        end
      end
    end
  end
  
  def wikify(str)
    redcloth = RedCloth.new(str)
    redcloth.gsub!(/\[\[(.*?)\]\]/u){ wikify_link($1) }
    auto_link redcloth.to_html
  end
    
  def wikify_link(str)
    permalink = PermalinkFu.escape(str)
    options = {}
    options[:class] = "new_wiki_link" unless Wikipage.find_by_permalink(permalink)
    link_to str, wikipage_path(@section, permalink), options
  end
    
  # def wikify_link(str)
  #   permalink = PermalinkFu.escape(str)
  #   if wikipage = Wikipage.find_by_permalink(permalink)
  #     link_to str, wikipage.home? ? wiki_path(@section) : wikipage_path(@section, permalink)
  #   else
  #     link_to str, wikipage_path(@section, permalink), :class => "new_wiki_link" 
  #   end
  # end
  
  def wiki_edit_links(wikipage, options = {})
    separator = options[:separator] || ' &middot; '
    
	  links = []	  
	  links << link_to('return to home', wiki_path(@section)) + separator unless wikipage.permalink == "home" 
    
	  if wikipage.version == wikipage.versions.last.version
	    links << authorized_tag(:span, :update, wikipage) do
	      link_to('edit this page', edit_wikipage_path(@section, wikipage.permalink)) + separator
      end
	    links << authorized_tag(:span, :delete, wikipage) do
	      link_to('delete this page', wikipage_path(@section, wikipage.permalink), { :confirm => "Are you sure you wish to delete this page?", :method => :delete }) + separator
      end unless wikipage.home?
    else
	    links << authorized_tag(:span, :update, wikipage) do
	      link_to('rollback to this revision', wikipage_path_with_home(@section, wikipage.permalink, :version => wikipage.version), { :confirm => "Are you sure you wish to rollback to this version?", :method => :put }) + separator
      end
    end

    if wikipage.versions.size > 1
      if wikipage.version > wikipage.versions.first.version
  	    links << link_to('view previous revision', wikipage_rev_path(:section_id => @section.id, :id => wikipage.permalink, :version => (wikipage.version - 1))) + separator
      end
      if wikipage.version < wikipage.versions.last.version - 1
  	    links << link_to('view next revision', wikipage_rev_path(:section_id => @section.id, :id => wikipage.permalink, :version => (wikipage.version + 1))) + separator
	    end
      if wikipage.version < wikipage.versions.last.version
  	    links << link_to('return to current revision', wikipage_path(@section, wikipage.permalink)) + separator
      end
    end
    
    links.join("\n").gsub(/#{separator}\Z/, '') # hackish, but no idea how to do it better
  end
  
end
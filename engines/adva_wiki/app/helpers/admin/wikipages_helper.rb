module Admin::WikipagesHelper
  def wiki_version_links(wikipage)
    links = []
    
    if wikipage.versions.count > 1
      if wikipage.version > wikipage.versions.first
  	    links << content_tag(:li) do
  	      link_to('View previous revision', edit_admin_wikipage_path(@site, @section, wikipage, :version => (wikipage.version - 1)))
	      end
      end
      if wikipage.version < wikipage.versions.last - 1
  	    links << content_tag(:li) do
  	      link_to('View next revision', edit_admin_wikipage_path(@site, @section, wikipage, :version => (wikipage.version + 1)))
	      end
	    end
      if wikipage.version < wikipage.versions.last
  	    links << content_tag(:li) do
  	      link_to('Return to current revision', edit_admin_wikipage_path(@site, @section, wikipage))
	      end
      end
      if wikipage.version != wikipage.versions.last
	      links << authorized_tag(:li, :update, wikipage) do
	        link_to('Rollback to this revision', admin_wikipage_path(@site, @section, wikipage, :version => wikipage.version), { :confirm => t(:'adva.wikipages_helper.wiki_version_links.confirm_rollback'), :method => :put })
        end
      end
    end
    
    links
  end
end
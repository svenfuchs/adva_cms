module Admin::WikipagesHelper
  def wiki_version_links(wikipage)
    links = []
    
    if wikipage.versions.size > 1
      if wikipage.version > wikipage.versions.first.version
  	    links << content_tag(:li) do
  	      link_to('View previous revision', edit_admin_wikipage_path(@site, @section, wikipage, :version => (wikipage.version - 1)))
	      end
      end
      if wikipage.version < wikipage.versions.last.version - 1
  	    links << content_tag(:li) do
  	      link_to('View next revision', edit_admin_wikipage_path(@site, @section, wikipage, :version => (wikipage.version + 1)))
	      end
	    end
      if wikipage.version < wikipage.versions.last.version
  	    links << content_tag(:li) do
  	      link_to('Return to current revision', edit_admin_wikipage_path(@site, @section, wikipage))
	      end
      end
      if wikipage.version != wikipage.versions.last.version
	      links << authorized_tag(:li, :update, wikipage) do
	        link_to('Rollback to this revision', admin_wikipage_path(@site, @section, wikipage, :version => wikipage.version), { :confirm => "Are you sure you wish to rollback to this version?", :method => :put })
        end
      end
    end
    
    links
  end
end
# Represents a cached page in the database.  Has one or more references that expire it.

class CachedPage < ActiveRecord::Base
  belongs_to :site
  validates_uniqueness_of :url, :scope => :site_id
  
  has_many :references, :class_name => "CachedPageReference", :dependent => :destroy

  class << self
    def find_by_reference(object, method = nil)
      sql = 'cached_page_references.object_type = ? AND cached_page_references.object_id = ?'      
      sql << ' AND cached_page_references.method = ?' if method

      conditions = [sql, object.class.name, object.id]
      conditions << method.to_s if method

      find :all, :conditions => conditions, :include => :references
    end
    
    def create_with_references(site, section, url, references)
      returning find_or_initialize_by_site_id_and_url(site.id, url, :include => :references) do |page|
        [:compact!, :uniq!].each { |method| references.send method }
        references.each do |object, method|
          reference = CachedPageReference.initialize_with(object, method)
          page.references << reference unless page.references.detect {|r| r == reference }
        end
        page.section_id = section.id if section
        page.cleared_at = nil
        page.save!
      end if site
    end

    def expire_pages(pages)
      destroy pages.collect(&:id) unless pages.empty?
    end
    
    def delete_all_by_site_id(site_id)
      delete_all "site_id = #{site_id}"
    end
  end
end
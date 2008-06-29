Section.delete_all

factories :site

factory :section,
        :site => lambda{ Site.find(:first) || create_site }
        
factory :blog, valid_section_attributes.update(:type => 'Blog', :title => 'the blog title'),
        :class => :section
        

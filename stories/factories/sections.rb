Section.delete_all

factories :site

factory :section,
        :site => lambda{ Site.find(:first) || create_site },
        :type => 'Section', 
        :title => 'the Section title'
        
factory :blog, valid_section_attributes.update(:type => 'Blog', :title => 'the blog title'),
        :class => :section
        
factory :wiki, valid_section_attributes.update(:type => 'Wiki', :title => 'the wiki title'),
        :class => :section
        


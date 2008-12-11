Section.delete_all

factories :site

factory :section,
        :site => lambda{ Site.find(:first) || create_site },
        :type => 'Section',
        :title => 'the Section title'

factory :blog, valid_section_attributes.update(:type => 'Blog', :title => 'the blog title'),
        :class => :section

factory :calendar, valid_section_attributes.update(:type => 'Calendar', :title => 'the calendar title'),
        :class => :section

factory :wiki, valid_section_attributes.update(:type => 'Wiki', :title => 'the wiki title'),
        :class => :section

factory :forum, valid_section_attributes.update(:type => 'Forum', :title => 'the forum title'),
        :class => :section

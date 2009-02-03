site = Site.find_by_name('site with sections')
superuser = User.find_by_first_name('a superuser')

album =
Album.create!  :site        => site,
               :title       => 'an album',
               :permalink   => 'an-album',
               :comment_age => 0

photo =
Photo.create!  :content_type => 'image/jpeg',
               :size         => 100,
               :title        => 'a photo',
               :author       => superuser,
               :filename     => 'test.png',
               :section      => album,
               :site        => site

Photo.create!  :content_type => 'image/jpeg',
               :size         => 110,
               :title        => 'a photo without set',
               :author       => superuser,
               :filename     => 'test.png',
               :section      => album,
               :site        => site

Photo.create!  :content_type => 'image/jpeg',
               :size         => 110,
               :title        => 'a published photo',
               :author       => superuser,
               :filename     => 'test.png',
               :section      => album,
               :published_at => Time.parse('2008-01-01 12:00:00'),
               :site        => site

set =    Category.create! :title => 'Summer', :section => album
subset = Category.create! :title => 'A Subset', :section => album
subset.move_to_child_of set

tag = Tag.create! :name => 'Forest'

photo.tags << tag
photo.sets << set

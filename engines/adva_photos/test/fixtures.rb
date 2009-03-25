site = Site.find_by_name('site with pages')
superuser = User.find_by_first_name('a superuser')

album =
Album.create!  :site        => site,
               :title       => 'an album',
               :permalink   => 'an-album',
               :comment_age => 0

basic_photo_attributes  = { :data_content_type => 'image/jpeg',
                            :data_file_name    => 'test.png',
                            # :size    => 100,
                            :author  => superuser,
                            :section => album }

published_photo_attributes = 
    basic_photo_attributes.merge(:published_at => Time.parse('2008-01-01 12:00:00'))

photo =
Photo.create!  basic_photo_attributes.merge(:title => 'a photo')

Photo.create!  basic_photo_attributes.merge(:title => 'a photo without set')

Photo.create!  published_photo_attributes.merge(:title => 'a published photo')

pub_photo_with_set =
Photo.create!  published_photo_attributes.merge(:title => 'a published photo with set')

pub_photo_with_set_and_tag =
Photo.create!  published_photo_attributes.merge(:title => 'a published photo with set and tag')

pub_photo_with_tag =
Photo.create!  published_photo_attributes.merge(:title => 'a published photo with tag')

set =    Category.create! :title => 'Summer', :section => album
subset = Category.create! :title => 'A Subset', :section => album
         Category.create! :title => 'Empty', :section => album

subset.move_to_child_of set

tag = Tag.create! :name => 'Forest'
      Tag.create! :name => 'Empty'

photo.tags << tag
photo.sets << set
pub_photo_with_tag.tags << tag
pub_photo_with_set.sets << set
pub_photo_with_set_and_tag.tags << tag
pub_photo_with_set_and_tag.sets << set

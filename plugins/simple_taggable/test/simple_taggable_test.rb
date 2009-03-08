require File.dirname(__FILE__) + '/test_helper'

class SimpleTaggableTest < ActiveSupport::TestCase
  fixtures :tags, :taggings, :photos, :posts, :subscriptions, :magazines, :users
  
  test 'tag_counts on class' do
    assert_tag_counts Photo.tag_counts, :great => 2, :sucks => 1, :crazy_animal => 1, :animal => 3, :nature => 3
    assert_tag_counts Post.tag_counts, :great => 2, :sucks => 2, :nature => 7
  end

  test 'tag_counts on instance' do
    assert_tag_counts @small_dog.tag_counts, :great => 2, :nature => 3, :animal => 3
  end

  test 'tag_counts with frequency' do
    assert_tag_counts Photo.tag_counts(:at_least => 2), :great => 2, :animal => 3, :nature => 3
    assert_tag_counts Photo.tag_counts(:at_most => 1), :sucks => 1, :crazy_animal => 1
  end
  
  test 'tag_counts with frequency and condition' do
    counts = Photo.tag_counts(:at_least => 2, :conditions => "tags.name LIKE '%n%'")
    assert_tag_counts counts, :animal => 3, :nature => 3
  end
  
  test 'tag_counts with order and limit' do
    assert_equal [@nature, @great], Post.tag_counts(:order => 'count DESC, name', :limit => 2)
  end
  
  test 'tag_counts on association' do
    assert_tag_counts @john.posts.tag_counts, :great => 1, :nature => 5, :sucks => 1
    assert_tag_counts @jane.posts.tag_counts, :great => 1, :nature => 2, :sucks => 1
      
    assert_tag_counts @john.photos.tag_counts, :great => 1, :sucks => 1, :crazy_animal => 1, :animal => 3, :nature => 1
    assert_tag_counts @jane.photos.tag_counts, :nature => 2, :great => 1
  end

  test 'tag_counts on association with options' do
    assert_equal [], @john.posts.tag_counts(:conditions => '1 = 0')
    assert_tag_counts @john.posts.tag_counts(:at_most => 2), :great => 1, :sucks => 1
  end

  test 'tag_counts on has_many :through' do
    assert_tag_counts @john.magazines.tag_counts, :great => 1
  end

  test 'has tags and taggings' do
    assert @small_dog.respond_to? :tags
    assert @small_dog.respond_to? :taggings
  end
  
  test '#tag_list' do
    assert_equal %w(Nature Animal Great), @small_dog.tag_list
  end
  
  test '#tagged finds records tagged with the given tags' do
    assert_equal [@bad_cat, @big_dog, @small_dog], Photo.tagged('Animal')
    assert_equal [@bad_cat], Photo.tagged('"Crazy animal"')
    assert_equal [@rain, @ground], Post.tagged('sucks')
  end
  
  test '#tagged does not find records tagged with nothing or blank tags' do
    assert_equal [], Photo.tagged("")
    assert_equal [], Photo.tagged([])
  end
  
  test '#tagged does not find records tagged with non existant tags' do
    assert_equal [], Post.tagged('doesnotexist')
    assert_equal [], Photo.tagged(['doesnotexist'])
    assert_equal [], Photo.tagged([Tag.new(:name => 'unsaved tag')])
  end
  
  test '#tagged finds records tagged with at least one of the given tags' do
    assert_equal [@bad_cat, @flower, @big_dog, @small_dog], Photo.tagged('Animal', 'Great')
  end
  
  test '#tagged finds records tagged with all of the given tags when :match_all option was set' do
    assert_equal [@small_dog], Photo.tagged('Animal', 'Great', :match_all => true)
  end
  
  test '#tagged using match_all and include' do
    assert_nothing_raised do
      Photo.tagged('Great', :include => :tags)
      Photo.tagged("Great", :include => { :taggings => :tag })
    end
  
    assert_equal [@small_dog], Photo.tagged(['Great', 'Animal'], :match_all => true, :include => :tags)
    assert_no_queries { @small_dog.tags }
  end
  
  test '#tagged using conditions' do
    assert_equal [], Photo.tagged('Great Nature', :conditions => '1 = 0')
  end
  
  test '#tagged using :except option' do
    assert_equal [@flower, @sky], Photo.tagged('Nature', :except => 'Animal')
  end
  
  test '#tagged with association scope' do
    assert_equal [@flower, @sky], @jane.photos.tagged('Nature')
    assert_equal [@small_dog], @john.photos.tagged('Nature')
    assert_equal [], @john.photos.tagged('Nature', :except => 'Animal')
    assert_equal [], @john.photos.tagged('Nature Bad', :match_all => true)
  end
  
  test '#save_tags saves new tags' do
    @small_dog.tag_list.add('New')
    @small_dog.save
    assert Tag.find_by_name('New')
    assert_equal %w(Nature Animal Great New), @small_dog.reload.tag_list
  end
  
  test '#save_tags removes old tags' do
    @small_dog.tag_list.remove('Great')
    @small_dog.save
    assert_equal %w(Nature Animal), @small_dog.reload.tag_list
  end
  
  test 'unused tags are deleted by default' do
    assert_difference('Tag.count', -1) do 
      @bad_cat.tag_list.remove('Crazy Animal')
      @bad_cat.save!
    end
  end
  
  test 'unused tags are not deleted when Tag.destroy_unused is set to false' do
    Tag.destroy_unused = false
    assert_no_difference('Tag.count') do 
      @big_dog.tag_list.remove('Animal')
      @big_dog.save!
    end
  end
  
  test '#tag_list reader returns a tag list' do
    assert_equivalent ['Sucks', 'Crazy Animal', 'Animal'], @bad_cat.tag_list
  end
  
  test 'adding new tags via #tag_list writer' do
    assert_equivalent %w(Nature), @sky.tag_list
    @sky.update_attributes!(:tag_list => "#{@sky.tag_list} One Two")
    assert_equivalent %w(Nature One Two), @sky.tag_list
  end
  
  test 'removing tags via #tag_list writer' do
    assert_equivalent %w(Nature), @sky.tag_list
    @sky.update_attributes!(:tag_list => "")
    assert_equivalent [], @sky.tag_list
  end
  
  test 'tag_list reader on a new record' do
    photo = Post.new(:text => 'Test')
    assert photo.tag_list.blank?
    photo.tag_list = "One, Two"
    assert_equal "One, Two", photo.tag_list.to_s
  end
  
  test 'tag_list writer clears tag_list with nil' do
    photo = @small_dog
    assert !photo.tag_list.blank?
    assert photo.update_attributes(:tag_list => nil)
    assert photo.tag_list.blank?
    assert photo.reload.tag_list.blank?
  end
  
  test 'tag_list writer clears tag_list with a string containing only spaces' do
    photo = @small_dog
    assert !photo.tag_list.blank?
    assert photo.update_attributes(:tag_list => '  ')
    assert photo.tag_list.blank?
    assert photo.reload.tag_list.blank?
  end
  
  test 'tag_list is reset on reload' do
    photo = @small_dog
    assert !photo.tag_list.blank?
    photo.tag_list = nil
    assert photo.tag_list.blank?
    assert !photo.reload.tag_list.blank?
  end
  
  test 'changing the case of tags via #tag_list writer' do
    @small_dog.update_attributes!(:tag_list => @small_dog.tag_list.to_s.upcase)
    assert_equal 'NATURE ANIMAL GREAT', @small_dog.reload.tag_list.to_s
  end
  
  test 'case insensivity' do
    assert_difference "Tag.count", 1 do
      Photo.create!(:title => "Foo", :tag_list => "baz")
      Photo.create!(:title => "Bar", :tag_list => "Baz")
      Photo.create!(:title => "Bar", :tag_list => "BAZ")
    end
  
    assert_equal Photo.tagged("baz"), Photo.tagged("BAZ")
  end
  
  test "tagged scope works with sti" do
    photo = SpecialPhoto.create!(:title => "Foo", :tag_list => "STI")
    assert_equal [photo], SpecialPhoto.tagged("STI")
    assert Photo.tagged("STI").map(&:id).include?(photo.id)
  end
  
  test 'caches the tag_list before save' do
    assert @small_dog.cached_tag_list.nil?
    @small_dog.save!
    assert_equal 'Nature Animal Great', @small_dog.cached_tag_list
  
    @small_dog.update_attributes(:tag_list => 'Foo')
    assert_equal 'Foo', @small_dog.cached_tag_list
    assert_equal 'Foo', @small_dog.reload.cached_tag_list
  end
  
  test 'cached_tag_list used' do
    @small_dog.save!
    @small_dog.reload
    assert_no_queries { assert_equal %w(Nature Animal Great), @small_dog.tag_list }
  end
end
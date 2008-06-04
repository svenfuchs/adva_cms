class Topic < ActiveRecord::Base
  # before_validation_on_create :set_default_attributes
  # after_create   :create_initial_post
  # before_update  :check_for_moved_forum
  # after_update   :set_post_forum_id
  # before_destroy :count_profile_posts_for_counter_cache
  # after_destroy  :update_cached_forum_and_profile_counts

  # # creator of forum topic
  # belongs_to :profile
  # 
  # # creator of recent post
  # belongs_to :last_profile, :class_name => "Profile"
  
  belongs_to :forum, :counter_cache => true, :class_name => 'Section'
  
  has_many :posts,       :order => "#{Post.table_name}.created_at", :dependent => :delete_all
  has_one  :recent_post, :order => "#{Post.table_name}.created_at DESC", :class_name => "Post"  

  # has_many :voices, :through => :posts, :source => :profile, :uniq => true  
  # has_many :monitorships, :dependent => :delete_all
  # has_many :monitoring_users, :through => :monitorships, :source => :profile, :conditions => {"#{Monitorship.table_name}.active" => true}
  
  validates_presence_of :forum_id, :title # :profile_id, 

  # attr_accessor :body
  # attr_accessible :title, :body
  # attr_readonly :posts_count, :hits
  
  has_permalink :title

  # def sticky?
  #   sticky == 1
  # end
  # 
  # def hit!
  #   self.class.increment_counter :hits, id
  # end
  # 
  # def paged?
  #   posts_count > Post.per_page
  # end
  # 
  # def last_page
  #   [(posts_count.to_f / Post.per_page.to_f).ceil.to_i, 1].max
  # end
  # 
  # def update_cached_post_fields(post)
  #   # these fields are not accessible to mass assignment
  #   if remaining_post = post.frozen? ? recent_post : post
  #     self.class.update_all(['last_updated_at = ?, last_profile_id = ?, last_post_id = ?, posts_count = ?', 
  #       remaining_post.created_at, remaining_post.profile_id, remaining_post.id, posts.count], ['id = ?', id])
  #   else
  #     self.destroy
  #   end
  # end

# protected
#   def create_initial_post
#     profile.reply self, @body unless locked?
#     @body = nil
#   end
#   
#   def set_default_attributes
#     self.group_id        = forum.group_id if forum
#     self.sticky          ||= 0
#     self.last_updated_at ||= Time.now.utc
#   end
# 
#   def check_for_moved_forum
#     old = Topic.find(id)
#     @old_forum_id = old.forum_id if old.forum_id != forum_id
#     true
#   end
# 
#   def set_post_forum_id
#     return unless @old_forum_id
#     posts.update_all :forum_id => forum_id
#     Forum.update_all "posts_count = posts_count - #{posts_count}", ['id = ?', @old_forum_id]
#     Forum.update_all "posts_count = posts_count + #{posts_count}", ['id = ?', forum_id]
#   end
#   
#   def count_profile_posts_for_counter_cache
#     @profile_posts = posts.group_by { |p| p.profile_id }
#   end
#   
#   def update_cached_forum_and_profile_counts
#     Forum.update_all "posts_count = posts_count - #{posts_count}", ['id = ?', forum_id]
#     Group.update_all  "posts_count = posts_count - #{posts_count}", ['id = ?', group_id]
#     @profile_posts.each do |profile_id, posts|
#       Profile.update_all "posts_count = posts_count - #{posts.size}", ['id = ?', profile_id]
#     end
#   end
end
class HasFilterArticle < ActiveRecord::Base
  set_table_name 'has_filter_articles'
  acts_as_taggable

  has_filter :tagged, :categorized,
             :text  => { :attributes => [:title, :body, :excerpt] },
             :state => { :states => [:published, :unpublished] }

  has_many :categories, :through => :categorizations, :class_name => 'HasFilterCategory'
  has_many :categorizations, :class_name => 'HasFilterCategorization', :dependent => :destroy

  named_scope :published, :conditions => 'published = 1'
  named_scope :approved, :conditions => 'approved = 1'
end

class HasFilterCategorization < ActiveRecord::Base
  belongs_to :article, :class_name => 'HasFilterArticle'
  belongs_to :category, :class_name => 'HasFilterCategory'
end

class HasFilterCategory < ActiveRecord::Base
end


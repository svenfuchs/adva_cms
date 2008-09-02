class Section < ActiveRecord::Base
  class Jail < Safemode::Jail
    allow :id, :type, :categories, :tag_counts
  end

  @@types = ['Section']
  cattr_reader :types

  acts_as_role_context :roles => :moderator
  permissions :article  => { :moderator => :all },
              :category => { :moderator => :all }
  serialize :permissions

  has_option :articles_per_page, :default => 15
  has_permalink :title, :scope => :site_id
  acts_as_nested_set
  has_many_comments
  instantiates_with_sti

  belongs_to :site
  has_many :articles, :foreign_key => 'section_id', :dependent => :destroy do
    def primary
      find_published :first, :order => :position
    end

    def permalinks
      find_published(:all).map(&:permalink)
    end
  end

  has_many :categories, :dependent => :destroy, :order => 'lft' do
    def roots
      find :all, :conditions => {:parent_id => nil}, :order => 'lft'
    end
  end

  before_validation :set_path, :set_comment_age

  validates_presence_of :title # :site wtf ... this breaks install_controller#index
  validates_uniqueness_of :permalink, :scope => :site_id
  validates_numericality_of :articles_per_page, :only_integer => true, :message => "can only be whole number."
  # TODO validates_inclusion_of :articles_per_page, :in => 1..30, :message => "can only be between 1 and 30."

  delegate :spam_engine, :to => :site

  class << self
    def register_type(type)
      @@types << type
      @@types.sort!.uniq!
    end
  end

  def owner
    site
  end

  def type
    read_attribute(:type) || 'Section'
  end

  def tag_counts
    Content.tag_counts :conditions => "section_id = #{id}"
  end

  def render_options(options = {:template => nil, :layout => nil})
    options.merge options.keys.inject({}) { |options, type|
      value = send(type)
      options[type] = value.sub /^templates\//, '' unless value.blank?
      options
    }
  end

  def root_section?
    self == site.sections.root
  end

  def accept_comments?
    comment_age.to_i > -1
  end

  protected

    def set_comment_age
      self.comment_age ||= -1
    end

    def set_path
      self.path = build_path
    end

    def build_path
      self_and_ancestors.map(&:permalink).join('/')
    end
end

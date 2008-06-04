class Section < ActiveRecord::Base
  class Jail < Safemode::Jail
    allow :id, :type, :categories, :tag_counts
  end  
  
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
  
  @@types = ['Section']
  cattr_reader :types
  
  serialize :required_roles
  class_inheritable_accessor :default_required_roles
  self.default_required_roles = { :manage_articles => :admin }
  
  option :articles_per_page, :default => 15    
  has_permalink :title, :scope => :site_id
  acts_as_nested_set
  acts_as_commentable
  instantiates_with_sti
  
  before_validation :set_path, :set_comment_age
  
  validates_presence_of   :title 
  # TODO with this the has_many association would not save the section when the 
  # site is saved? see http://pastie.caboo.se/197461
  # validates_presence_of :site_id 
  validates_uniqueness_of :permalink, :scope => :site_id

  class << self
    def register_type(type)
      @@types << type
      @@types.sort!.uniq!
    end
    
    # def factory(attributes)
    #   attributes ||= {}
    #   attributes[:type] ||= 'Section'
    #   attributes.delete(:type).constantize.new attributes
    # end
    
    def paths(host)
      find(:all, :conditions => ["path <> '' AND sites.host = ?", host], :include => :site).map(&:path)
    end
    
    def find_by_host_and_path(host, path)
      find(:first, :conditions => ["path = ? AND sites.host = ?", path, host], :include => :site)
    end
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
  
  def user_has_role?(user, role)    
    !!user.detect_role(role, self) or site.user_has_role?(user, role)
  end
  
  def required_roles
    @required_roles ||= begin
      roles = read_attribute(:required_roles) || {}
      default_required_roles.update roles.symbolize_keys
    end
  end
  
  def required_role_for(permission)
    required_roles[permission] || site.required_role_for(permission)
  end

  protected
  
    def set_comment_age
      self.comment_age ||= -1
    end
  
    def set_path
      self.path = build_path
    end
  
    def build_path
      self_and_ancestors.map(&:permalink).join('/') #.gsub(%r(^#{site.sections.root.path}/?), '')
    end
end

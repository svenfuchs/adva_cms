class Page < Section
  has_option :single_article_mode, :default => true, :type => :boolean

  has_many :articles, :foreign_key => 'section_id', :dependent => :destroy do
    def primary
      published(:order => :position, :limit => 1).first
    end

    def permalinks
      published.map(&:permalink)
    end
  end

  class << self
    def content_type
      'Article'
    end
  end
end
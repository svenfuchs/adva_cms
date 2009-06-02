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

  def published_at
    return articles.first.published_at if single_article_mode && articles.first
    super
  end

  def published_at=(published_at)
    if single_article_mode && articles.first
      articles.first.update_attribute(:published_at, published_at)
    else
      super
    end
  end

  def published?(parents=false)
    if single_article_mode
      # FIXME: duplication with Section class
      return true if self == site.sections.root
      return false if parents && !ancestors.reject(&:published?).empty?
      return articles.first ? articles.first.published? : false
    end
    super
  end
end
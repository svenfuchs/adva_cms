class BaseCell < Cell::Base
  protected
    def symbolize_options!
      @opts.symbolize_keys!
    end

    def set_site
      @site = controller.site or raise "can not set site from controller"
    end

    def set_section
      if section = @opts[:section]
        @section = @site.sections.find(:first, :conditions => ["id = ? OR permalink = ?", section, section])
      end
      @section ||= controller.section
      @section ||= @site.sections.root
    end

    # TODO make this a class level dsl, so cells can say something like:
    # has_option :include_child_section => {:type => :boolean, :default => true}
    def include_child_sections?
      boolean_option(:include_child_sections)
    end

    def boolean_option(key)
      value = @opts[key]
      !!(value.blank? || value == 'false' || value == '0' ? false : true)
    end

    def with_sections_scope(klass, &block)
      conditions = include_child_sections? ?
        ["(sections.lft >= ?) and (sections.rgt <= ?)", @section.lft, @section.rgt] :
        { :section_id => @section.id }
      options = { :find => { :conditions => conditions, :include => 'section' }}

      klass.send :with_scope, options, &block
    end
end
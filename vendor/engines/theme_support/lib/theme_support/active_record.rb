module ThemeSupport
  module ActiveRecord  
    def self.included(base)
      base.class_eval do 
        extend ActMacro
        delegate :acts_as_themed?, :to => "self.class"
      end
    end
  
    module ActMacro
      def acts_as_themed(options = {})
        return if acts_as_themed?
        include InstanceMethods 
        
        serialize :theme_names, Array
  
        before_destroy :destroy_themes
        
        validates_each 'theme_names' do |record, attr, value|
          record.theme_names.each do |theme_name|
            record.errors.add('theme_name', "may not contain slashes") if theme_name =~ /[\\\/]+/
          end if record.theme_names
        end

        options[:default] ||= 'default'
        options[:prefix]  ||= "#{name.downcase}-"

        write_inheritable_attribute(:theme_prefix, options[:prefix])
        write_inheritable_attribute(:theme_default, options[:default])        
      end
    
      def acts_as_themed?
        included_modules.include?(ThemeSupport::ActiveRecord::InstanceMethods)
      end
    end
    
    module InstanceMethods   
      def theme_names
        self[:theme_names] ||= []
      end
                         
      def themes_dir
        File.join Theme.base_dir, theme_subdir
      end
      
      def theme_subdir
        "#{theme_prefix}#{id}/"
      end
        
      def theme_paths
        (theme_names.empty? ? [theme_default] : theme_names).map{|theme_name| theme_subdir + theme_name }
      end
      
      def current_themes
        @current_themes ||= themes.find(theme_names)
      end
  
      def current_theme?(theme)
        theme_names.include? theme.id
      end
      
      def current_theme_template_paths(include_layouts = false)
        @current_theme_template_paths ||= begin
          returning current_themes.map(&:templates).flatten.map(&:localpath).map(&:to_s) do |paths|
            paths.reject!{|path| path =~ %r(/layouts/) } unless include_layouts
          end
        end
      end
      
      def current_theme_layout_paths
        @current_theme_layout_paths ||= begin
          current_theme_template_paths(true).select{|path| path =~ %r(/layouts/) }
        end
      end
      
      def themes
        # let's have ActiveRecord like association finders
        @themes ||= Class.new(Hash) do
          def find(id)
            Theme.find(id, fetch(:owner).theme_subdir)
          end
          
          def build(attributes)
            Theme.new(attributes.merge :path => fetch(:owner).themes_dir)
          end
          
          def import(file)
            theme = Theme.import(file)
            path = Pathname.new fetch(:owner).themes_dir + Theme.to_id(theme.name)
            tmp_path = theme.path
            path.rmtree if path.exist? # TODO look for a unique name if this one is already taken?
            theme.about_file.mv path + 'about.yml' # TODO maybe make this Theme#mv instead of copying the actual dir?
            theme.files.flatten.each do |file|
              file.mv path + file.localpath if file.valid?
            end
            FileUtils.rm_r tmp_path.dirname
          end
        end[:owner, self]
      end
      
      private
     
      def theme_prefix
        self.class.read_inheritable_attribute(:theme_prefix)
      end
      
      def theme_default
        self.class.read_inheritable_attribute(:theme_default)
      end
  
      def destroy_themes
        File.exists?(themes_dir) ? FileUtils.rm_r(themes_dir) : true
      rescue
        logger.error "ERROR: removing directories for site #{self.host}: #{themes_dir}, check file permissions."
        false
      end
    end
  end
end

ActiveRecord::Base.send :include, ThemeSupport::ActiveRecord  
module ThemeAssetTagHelper
  def theme_image_tag(theme_name, source, options = {})
    image_tag *add_theme_path(theme_name, source)
  end

  def theme_stylesheet_link_tag(theme_name, *sources)
    sources = [theme_name] if sources.empty?
    stylesheet_link_tag *add_theme_paths(theme_name, sources)
  end

  def theme_javascript_include_tag(theme_name, *sources)    
    sources = [theme_name] if sources.empty?
    javascript_include_tag *add_theme_paths(theme_name, sources)
  end

  def add_theme_paths(theme_name, sources)
    sources.collect {|source| source.is_a?(Hash) ? source : add_theme_path(theme_name, source) }
  end

  def add_theme_path(theme_name, source)
    if theme = controller.current_themes.detect{|theme| theme.id == theme_name.to_s.downcase}
      "themes/#{theme.id}/#{source}"
    else
      raise "could not find theme #{theme_name}"
    end
  end
end
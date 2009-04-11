module ThemesHelper
  def link_to_deactivate_theme(theme)
    link_to(t(:'adva.themes.links.deactivate'), admin_site_selected_theme_path(theme.site, theme, :return_to => request.url),
            :confirm => t(:'adva.themes.confirm_deactivate'), :method => :delete)
  end

  def link_to_activate_theme(theme)
    link_to(t(:'adva.themes.links.activate'), admin_site_selected_themes_path(theme.site, :id => theme.id, :return_to => request.url),
            :confirm => t(:'adva.themes.confirm_activate'), :method => :post)
  end

  def link_to_delete_theme_file(file)
    link_to(t(:'adva.theme_files.links.delete'), admin_theme_file_path(file.theme.site, file.theme.id, file.id),
            :confirm => t(:'adva.theme_files.confirm_delete'), :method => :delete)
  end
end
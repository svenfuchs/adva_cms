ActionController::Dispatcher.to_prepare do
  # FIXME move the theme role contexts to adva_theme (after integration of new rbac)
  Site.acts_as_role_context    :actions => ["manage themes", "manage assets"]
  Section.acts_as_role_context :actions => ["create article", "update article", "delete article"], :parent => Site
  Content.acts_as_role_context :parent => Section
end
config.to_prepare do
  Section.register_type 'Wiki'
end

register_javascript_expansion :admin  => %w( adva_wiki/admin/wiki.js )
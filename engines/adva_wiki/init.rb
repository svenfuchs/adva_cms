I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config', 'locales', '**/*.{rb,yml}')]

config.to_prepare do
  Section.register_type 'Wiki'
end

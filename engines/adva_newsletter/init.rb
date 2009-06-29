I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config', 'locales', '**/*.{rb,yml}')]

register_javascript_expansion :admin => %w( adva_newsletter/admin/newsletter )
register_stylesheet_expansion :login => %w( adva_newsletter/subscription )

#default values
Registry.instance[:number_of_outgoing_mails_per_process] = 150 if Registry.instance[:number_of_outgoing_mails_per_process].blank?
Registry.instance[:email_header]["X-Mailer"] = "Adva-CMS" if Registry.instance[:email_header].blank?

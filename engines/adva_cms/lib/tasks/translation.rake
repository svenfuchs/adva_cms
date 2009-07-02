namespace :adva do
  namespace :i18n do
    #Define locales root
    language_root = Rails.root.join("vendor/plugins/adva_cms/locale/adva_cms/")
    base_language = "en"

    desc "Check differences in locale files"
    task :check do
      base = YAML::load_file("#{language_root}#{base_language}.yml")
      base_keys = all_keys(base, base_language)

      Dir["#{language_root}*.yml"].each do |f|
        language = File.basename(f,".yml")
        next if language == base_language

        comp = YAML::load_file("#{language_root}#{language}.yml")
        comp_keys = all_keys(comp, language)

        puts "MISSING KEYS IN #{language.upcase!}"
        puts base_keys - comp_keys
        puts "EXTRA KEYS IN #{language}"
        puts comp_keys - base_keys
      end
    end
    
    desc "Migrate section and category titles. Specify e.g., LOCALE=de if app locale isn't en."
    task :migrate_titles => :environment do
      locale = ENV['locale'] || 'en'
      connection = ActiveRecord::Base.connection
      sql = %{
        INSERT INTO section_translations (section_id, locale, title, created_at, updated_at)
        SELECT sections.id, "#{locale}", sections.title, sections.published_at, sections.published_at
        FROM sections
      }
      connection.insert sql, "migrating sections to globalize"
      connection.remove_column 'sections', 'title'

      t = ActiveRecord::Base.default_timezone == :utc ? Time.now.utc : Time.now
      qt = connection.quote(t)
      sql = %{
        INSERT INTO category_translations (category_id, locale, title, created_at, updated_at)
        SELECT categories.id, #{connection.quote(locale)}, categories.title, #{qt}, #{qt}
        FROM categories
      }
      connection.insert sql, "migrating categories to globalize"
      connection.remove_column 'categories', 'title'

      Rake::Task['db:schema:dump'].invoke
    end
  end
end

def all_keys(h, language)
  r_keys(h[language]).flatten! # we exclude the top level key
end

# Returns all keys in a hash recursively, prepending the previous key name
def r_keys(h,prev = "")
  keys = []
  if h.is_a?(Hash)
    h.each do |k,v|
      key = prev.blank? ? k : "#{prev}:#{k}"
      keys << key
      sub = r_keys(v, key)
      keys << sub unless sub.empty?
    end
  end
  keys
end

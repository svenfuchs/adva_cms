module Globalize
  module Model
    class Adapter
      def update_translations!
        @stash.each do |locale, attrs|
          next if attrs.empty?
          ::ActiveRecord::Base.transaction do
            translation = nil
            if @record.versioned?
              translation = @record.globalize_translations.find_or_initialize_by_locale_and_current(locale.to_s, true)
              translation.version ||= 1
              if @record.save_version?
                translation = translation.clone unless @record.new_record?
                translation.version = highest_version + 1
              end
              if translation.new_record?
                translation.class.update_all( [ 'current = ?', false ],
                  [ "current=? AND locale=? AND #{reference_field}=?",
                  true, locale.to_s, @record.id ] )
              else
              translation.class.update_all( [ 'current = ?', false ],
                  [ "current=? AND locale=? AND #{reference_field}=? AND id != ?",
                  true, locale.to_s, @record.id, translation.id ] )
              end
              translation.current = true
            else
              translation = @record.globalize_translations.find_or_initialize_by_locale(locale.to_s)
            end
            attrs.each{|attr_name, value| translation[attr_name] = value }
            translation.save!
          end
        end
        @stash.clear
      end

      def highest_version(locale = ::ActiveRecord::Base.locale)
        @record.globalize_translations.maximum(:version,
          :conditions => { :locale => locale.to_s, reference_field => @record.id }) || 0
      end

      def reference_field
        @record.class.base_class.name.underscore + '_id'
      end
    end

    module ActiveRecord
      module Translated
        module Callbacks
          def globalize2_versioning
            if globalize_options[:versioned].blank?
              define_method :'versioned?', lambda { false }
            else
              include Versioned::InstanceMethods
              extend  Versioned::ClassMethods
              class_inheritable_accessor :max_version_limit
              self.max_version_limit = globalize_options[:limit].to_i
              after_save :clear_old_versions
            end
          end
        end
        module Extensions
          def by_locales(locales)
            if proxy_owner.versioned?
              find :all, :conditions => { :locale => locales.map(&:to_s), :current => true }
            else
              find :all, :conditions => { :locale => locales.map(&:to_s) }
            end
          end
        end
      end

      module Versioned
        module ClassMethods
          def versioned_attributes
            globalize_options[:versioned]
          end

          def create_translation_table!(fields)
            translated_fields = self.globalize_options[:translated_attributes]
            translated_fields.each do |f|
              raise MigrationMissingTranslatedField, "Missing translated field #{f}" unless fields[f]
            end
            fields.each do |name, type|
              unless translated_fields.member? name
                raise UntranslatedMigrationField, "Can't migrate untranslated field: #{name}"
              end
              unless [ :string, :text ].member? type
                raise BadMigrationFieldType, "Bad field type for #{name}, should be :string or :text"
              end
            end
            translation_table_name = self.name.underscore + '_translations'
            self.connection.create_table(translation_table_name) do |t|
              t.references self.table_name.singularize
              t.string :locale
              unless globalize_options[:versioned].blank?
                t.integer     :version
                t.boolean     :current
              end
              fields.each do |name, type|
                t.column name, type
              end
              t.timestamps
            end
          end

          def drop_translation_table!
            translation_table_name = self.name.underscore + '_translations'
            self.connection.drop_table translation_table_name
          end
        end

        module InstanceMethods
          def versioned?; true end

          def version(locale = self.class.locale)
            translation = globalize_translations.find_by_locale_and_current(locale.to_s, true)
            translation ? translation.version : nil
          end

          def revert_to(version, locale = self.class.locale)
            version = version.to_i
            return true if version == self.version
            new_translation = globalize_translations.find_by_locale_and_version(locale.to_s, version)
            return false unless new_translation
            translation = globalize_translations.find_by_locale_and_current(locale.to_s, true)
            transaction do
              translation.update_attribute :current, false
              new_translation.update_attribute :current, true
            end

            # clear out cache
            globalize.clear
            true
          end

          def save_without_revision
            @no_revision = true
            result = save
            @no_revision = false
            result
          end

          # Checks whether a new version should be saved or not.
          def save_version?
            return false  if @no_revision
            return true   if new_record?
            change_fields = globalize_options[:if_changed].blank? ?
              globalize_options[:versioned] : globalize_options[:if_changed]
            ( change_fields.map {|k| k.to_s } & changed ).length > 0
          end

          def versions
            @globalize_version_proxy ||= ProxyHelper.new self
          end

          private

          def clear_old_versions(locale = self.class.locale)
            if self.class.max_version_limit > 0
              old_version = version - self.class.max_version_limit
              if old_version > 0
                "#{self.class.base_class.name}Translation".constantize.delete_all [
                  "version <= ? AND locale = ? AND #{globalize.reference_field} = ?",
                  old_version, locale.to_s, self.id ]
              end
            end
          end

        end # InstanceMethods

        class ProxyHelper
          def initialize(rec)
            @rec = rec
          end

          def [](ver)
            rec = @rec.globalize_translations.find_by_locale_and_version( @rec.class.locale.to_s, ver )
            rec.readonly! if rec
            rec
          end

          def count
            @rec.globalize_translations.count( :conditions => [ 'locale = ?', @rec.class.locale.to_s ] )
          end

          def first
            @rec.globalize_translations.minimum( :version, :conditions => [ 'locale = ?', @rec.class.locale.to_s ] )
          end

          def second
            rec = @rec.globalize_translations.first :conditions => [ 'locale = ?', @rec.class.locale.to_s ],
              :offset => 1, :order => 'version ASC'
            rec && rec.version
          end

          def third
            rec = @rec.globalize_translations.first :conditions => [ 'locale = ?', @rec.class.locale.to_s ],
              :offset => 2, :order => 'version ASC'
            rec && rec.version
          end

          def last
            @rec.globalize_translations.maximum( :version, :conditions => [ 'locale = ?', @rec.class.locale.to_s ] )
          end

          def empty?
            count == 0
          end
        end

      end   # Versioned
    end     # ActiveRecord
  end       # Model
end         # Globalize
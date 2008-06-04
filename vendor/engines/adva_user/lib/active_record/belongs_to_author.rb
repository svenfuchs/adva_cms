# Provides a common facade for models that reference User and Anonymous as
# their author:
#
#   belongs_to :author, :polymorphic => true
#
# It also caches the attributes name, email and homepage locally in the model
# so that users and anonymouses can be deleted without compromising the data
# integrity (although users might still want to act_as_paranoid).
#
# Currently used by Content, Comment and Activity.

module ActiveRecord
  module BelongsToAuthor
    def self.included(base)
      base.extend ActMacro  
    end

    module ActMacro
      def belongs_to_author(options = {})
        return if belongs_to_author?
        belongs_to :author, :polymorphic => true # TODO :with_deleted => true
        validates_presence_of :author_id
        before_save :cache_author_attributes!
        
        include InstanceMethods
      end

      def belongs_to_author?
        included_modules.include?(InstanceMethods)
      end
    end
  
    module InstanceMethods  
      def author_name
        author ? author.name : read_attribute(:author_name)
      end  
  
      def author_email
        author ? author.email : read_attribute(:author_email)
      end  
  
      def author_homepage
        author ? author.homepage : read_attribute(:author_homepage)
      end
  
      def author_link(options = {})
        text = options[:include_email] ? "#{author_name} (#{author_email})" : author_name
        author_homepage.blank? ? text : %Q(<a href="#{author_homepage}">#{author_name}</a>)
      end 

      def is_author?(author)
        author.id == self.author_id && author.class.name == self.author_type
      end  
      
      private
        def cache_author_attributes!
          self.author_name = author.name
          self.author_email = author.email
          self.author_homepage = author.homepage
        end
    end
  end
end
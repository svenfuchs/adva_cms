$LOAD_PATH << File.dirname(__FILE__) + '/../lib/'

ENV["RAILS_ENV"] = "test"

require 'rubygems'
require 'active_record'

ActiveRecord::Base.class_eval do 
  class << self
    # no peeping toms (aka observers) wanted here
    alias_method :dont_instantiate_observers, :instantiate_observers
    def instantiate_observers; end
  end
end

require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'spec'
require 'spec/rails'

config = {'adapter' => 'sqlite3', 'dbfile' => File.dirname(__FILE__) + '/has_counter.sqlite3.db'}
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/has_counter.spec.log')
ActiveRecord::Base.establish_connection(config)

require 'counter'
unless Counter.table_exists?
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Schema.define(:version => 1) do
    create_table :counters, :force => true do |t|
      t.references :owner, :polymorphic => true
      t.string     :name, :limit => 25
      t.integer    :count, :default => 0
    end
  end
end

module CounterSpec
  class Comment < ActiveRecord::Base
    set_table_name 'comments'
    
    belongs_to :content
    after_save    :update_commentable
    after_destroy :update_commentable
    
    unless table_exists?
      ActiveRecord::Migration.verbose = false
      ActiveRecord::Schema.define(:version => 1) do
        create_table :comments, :force => true do |t|
          t.references :content
          t.text :text
          t.integer :approved
        end
      end
    end

    def unapproved?
      !approved?
    end
  
    def just_approved?
      approved? && approved_changed?
    end
  
    def just_unapproved?
      !approved? && approved_changed? 
    end
  
    def update_commentable
      content.after_comment_update(self)
    end 
  end

  class Content < ActiveRecord::Base
    set_table_name 'contents'
    
    has_many :comments
    
    has_counter :comments, 
                :class_name => 'CounterSpec::Comment'
                
    has_counter :approved_comments, 
                :class_name => 'CounterSpec::Comment', 
                :after_create => false,
                :after_destroy => false
                # :after_destroy => lambda{|record| 
                #   :decrement! if record.approved? 
                # },
                # :after_save => lambda{|record| 
                #   record.just_approved? && :increment! or
                #   record.just_unapproved? && :decrement!
                # }
                
    def after_comment_update(comment)
      method = if comment.frozen? && comment.approved?
        :decrement!
      elsif comment.just_approved? 
        :increment!
      elsif comment.just_unapproved? 
        :decrement!
      end
      approved_comments_counter.send method if method
    end

    unless table_exists?
      ActiveRecord::Migration.verbose = false
      ActiveRecord::Schema.define(:version => 1) do
        create_table :contents, :force => true do |t|
          t.string :title, :limit => 50
        end
      end
    end
  end
end






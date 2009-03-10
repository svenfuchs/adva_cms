# Include hook code here
require 'globalize2_versioning'
ActiveRecord::Base.send :include, Globalize::Model::ActiveRecord::Versioned

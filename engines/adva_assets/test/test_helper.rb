defined?(ASSET_TEST_HELPER_LOADED) ? raise("can not load #{__FILE__} twice") : ASSET_TEST_HELPER_LOADED = true

require File.expand_path(File.dirname(__FILE__) + '/../../adva_cms/test/test_helper')

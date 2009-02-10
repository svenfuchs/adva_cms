require File.expand_path(File.dirname(__FILE__) + '/../../adva_cms/test/test_helper')
Time.stubs(:now).returns Time.utc(2009,2,3, 15,00,00)
Date.stubs(:today).returns Date.civil(2009,2,3)


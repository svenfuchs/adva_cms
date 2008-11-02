dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

module CacheableFlash
  describe TestHelpers do
    attr_reader :controller, :request, :response, :flash
    before do
      @controller = ActionController::Base.new
      @request = ActionController::TestRequest.new
      @response = ActionController::TestResponse.new
      controller.send(:initialize_template_class, response)
      controller.send(:assign_shortcuts, request, response)

      @flash = controller.send(:flash)
      class << controller
        include CacheableFlash
      end
    end

    describe "#flash_cookie" do
      it "returns the flash hash send as a cookie" do
        expected_flash = {
        'errors' => "This is an Error",
        'notice' => "This is a Notice"
        }
        flash['errors'] = expected_flash['errors']
        flash['notice'] = expected_flash['notice']
        controller.write_flash_to_cookie

        flash_cookie.should == expected_flash
      end
    end
  end
end

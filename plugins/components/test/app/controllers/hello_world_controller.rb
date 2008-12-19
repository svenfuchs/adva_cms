class HelloWorldController < ActionController::Base
  def say_it
    render :text => component("hello_world/say_it", params[:string])
  end
end
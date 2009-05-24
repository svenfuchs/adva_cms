class BaseController < ApplicationController
  around_filter OutputFilter::Cells.new
end




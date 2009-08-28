class Admin::CellsController < Admin::BaseController
  def index
    @cells = Cell.all
    p @cells

    respond_to do |format|
      format.xml { render :xml => @cells.to_xml(:root => 'cells', :skip_types => true) }
    end
  end
end
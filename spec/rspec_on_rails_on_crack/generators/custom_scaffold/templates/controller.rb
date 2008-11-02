class <%= controller_class_name %>Controller < ApplicationController
  def index
    @<%= table_name %> = <%= class_name %>.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @<%= table_name %> }
      format.json { render :json => @<%= table_name %> }
    end
  end

  def show
    @<%= file_name %> = <%= class_name %>.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @<%= file_name %> }
      format.json { render :json => @<%= file_name %> }
    end
  end

  def new
    @<%= file_name %> = <%= class_name %>.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @<%= file_name %> }
      format.json { render :json => @<%= file_name %> }
    end
  end

  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = '<%= class_name %> was successfully created.'
        format.html { redirect_to(@<%= file_name %>) }
        format.xml  { render :xml  => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
        format.json { render :json => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml  => @<%= file_name %>.errors, :status => :unprocessable_entity }
        format.json { render :json => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @<%= file_name %> = <%= class_name %>.find(params[:id])
  end

  def update
    @<%= file_name %> = <%= class_name %>.find(params[:id])

    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = '<%= class_name %> was successfully updated.'
        format.html { redirect_to(@<%= file_name %>) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @<%= file_name %>.errors, :status => :unprocessable_entity }
        format.json { render :json => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @<%= file_name %> = <%= class_name %>.find(params[:id])
    @<%= file_name %>.destroy

    respond_to do |format|
      format.html { redirect_to(<%= table_name %>_url) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end

class DynamicDescriptionsController < ApplicationController
  # GET /dynamic_descriptions
  # GET /dynamic_descriptions.xml
  def index
    @dynamic_descriptions = DynamicDescription.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dynamic_descriptions }
    end
  end

  # GET /dynamic_descriptions/1
  # GET /dynamic_descriptions/1.xml
  def show
    @dynamic_description = DynamicDescription.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dynamic_description }
    end
  end

  # GET /dynamic_descriptions/new
  # GET /dynamic_descriptions/new.xml
  def new
    @dynamic_description = DynamicDescription.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dynamic_description }
    end
  end

  # GET /dynamic_descriptions/1/edit
  def edit
    @dynamic_description = DynamicDescription.find(params[:id])
  end

  # POST /dynamic_descriptions
  # POST /dynamic_descriptions.xml
  def create
    @dynamic_image = DynamicImage.where("uid = ? AND image_location = ?", params[:uid], params[:image_location]).first
    if(@dynamic_image.nil?)
      @dynamic_image = DynamicImage.new(:uid => params[:uid], :image_location => params[:image_location], :title => params[:title])
      @dynamic_image.save
    end
    @dynamic_description = @dynamic_image.dynamic_descriptions.create(params[:dynamic_description])

    respond_to do |format|
      if @dynamic_description.save
        format.html { redirect_to(@dynamic_description, :notice => 'Dynamic description was successfully created.') }
        format.xml  { render :xml => @dynamic_description, :status => :created, :location => @dynamic_description }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dynamic_description.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dynamic_descriptions/1
  # PUT /dynamic_descriptions/1.xml
  def update
    @dynamic_description = DynamicDescription.find(params[:id])

    respond_to do |format|
      if @dynamic_description.update_attributes(params[:dynamic_description])
        format.html { redirect_to(@dynamic_description, :notice => 'Dynamic description was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dynamic_description.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dynamic_descriptions/1
  # DELETE /dynamic_descriptions/1.xml
  def destroy
    @dynamic_description = DynamicDescription.find(params[:id])
    @dynamic_description.destroy

    respond_to do |format|
      format.html { redirect_to(dynamic_descriptions_url) }
      format.xml  { head :ok }
    end
  end
end

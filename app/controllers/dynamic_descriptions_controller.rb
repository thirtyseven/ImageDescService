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
    if params[:uid] && params[:image_location]
      @dynamic_image = DynamicImage.where("uid = ? AND image_location = ?", params[:uid], params[:image_location]).first
      if(@dynamic_image.nil?)
        @dynamic_image = DynamicImage.new(:uid => params[:uid], :image_location => params[:image_location], :title => params[:title])
        @dynamic_image.save
      end
      @dynamic_description = @dynamic_image.dynamic_descriptions.create(params[:dynamic_description])
    else
      @dynamic_description = DynamicDescription.new
      @dynamic_description.body = "missing parameters"
      @missing_parameters = true
    end

    respond_to do |format|
      if @missing_parameters
        format.html { render :action => "new" }
        format.xml  { render :xml => @dynamic_description, :status => :non_authoritative_information }
        format.json  { render :json => @dynamic_description, :callback => params[:callback], :status => :non_authoritative_information }
      elsif @dynamic_description.save
        format.html { redirect_to(@dynamic_description, :notice => 'Dynamic description was successfully created.') }
        format.xml  { render :xml => @dynamic_description, :status => :created, :location => @dynamic_description }
        format.json  { render :json => @dynamic_description, :callback => params[:callback], :status => :created, :location => @dynamic_description }
      else
        @uid = params[:uid]
        @image_location = params[:image_location]
        format.html { render :action => "new" }
        format.xml  { render :xml => @dynamic_description.errors, :status => :non_authoritative_information }
        format.json  { render :json => @dynamic_description.errors, :callback => params[:callback], :status => :non_authoritative_information }
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

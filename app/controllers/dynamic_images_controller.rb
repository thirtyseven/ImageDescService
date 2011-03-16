class DynamicImagesController < ApplicationController
  # GET /dynamic_images
  # GET /dynamic_images.xml
  def index
    @dynamic_images = DynamicImage.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dynamic_images }
    end
  end

  # GET /dynamic_images/1
  # GET /dynamic_images/1.xml
  # GET /dynamic_images/1.json
  def show
    if params[:uid] && params[:image_location] && !params[:uid].empty?
      @dynamic_image = DynamicImage.where("uid = ? AND image_location = ?", params[:uid], params[:image_location]).first
      if @dynamic_image
        @last_desc = @dynamic_image.dynamic_descriptions.last
      else
        @last_desc = DynamicDescription.new
        @last_desc.body = "no description found"
        @status = :no_content
      end
    else
      @last_desc = DynamicDescription.new
      @last_desc.body = "missing parameter"
      @status = :non_authoritative_information
    end

    respond_to do |format|
      if @dynamic_image
        format.html # show.html.erb
        format.xml  { render :xml => @last_desc }
        format.json { render :json => @last_desc, :callback => params[:callback]}
      else
        format.html
        format.xml { render :xml => @last_desc, :status => @status}
        format.json { render :json => @last_desc, :callback => params[:callback], :status => @status}
      end
    end
  end

  # GET /dynamic_images/new
  # GET /dynamic_images/new.xml
  def new
    @dynamic_image = DynamicImage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dynamic_image }
    end
  end

  # GET /dynamic_images/1/edit
  def edit
    @dynamic_image = DynamicImage.find(params[:id])
  end

  # POST /dynamic_images
  # POST /dynamic_images.xml
  def create
    @dynamic_image = DynamicImage.new(params[:dynamic_image])

    respond_to do |format|
      if @dynamic_image.save
        format.html { redirect_to(@dynamic_image, :notice => 'Image description successfully entered!') }
        format.xml  { render :xml => @dynamic_image, :status => :created, :location => @dynamic_image }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dynamic_image.errors, :status => :not_found }
      end
    end
  end

end

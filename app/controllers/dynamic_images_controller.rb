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
    if params[:book_uid] && params[:image_location] && !params[:book_uid].empty?
      @dynamic_image = DynamicImage.where("book_uid = ? AND image_location = ?", params[:book_uid], params[:image_location]).first
      if @dynamic_image
        @last_desc = @dynamic_image.dynamic_descriptions.last
      else
        @last_desc = DynamicDescription.new
        @last_desc.body = "no description found"
        @status = :no_content
      end
    else
      @last_desc = DynamicDescription.new
      @last_desc.body = "missing parameter uid=#{params[:book_uid]}, loc=#{params[:image_location]}"
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

  def show_history
    if params[:book_uid] && params[:image_location] && !params[:book_uid].empty?
      @descriptions = DynamicImage.find_by_sql("select d.* from dynamic_images as i, dynamic_descriptions as d where i.book_uid = '#{params[:book_uid]}' and image_location = '#{params[:image_location]}' and i.id = d.dynamic_image_id order by created_at desc")
      render :layout => false
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
  
  def update
    image = DynamicImage.find(params[:id])
    image_params = params[:dynamic_image]
    image.should_be_described = image_params[:should_be_described]
    image.save
    render :text=>"submitted #{params[:id]}: #{params[:dynamic_image]}",  :content_type => 'text/plain'
  end

end

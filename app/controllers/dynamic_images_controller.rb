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
  def show

    @dynamic_image = DynamicImage.where("uid = ? AND image_location = ?", params[:uid], params[:image_location]).first
    @last_desc = @dynamic_image.dynamic_descriptions.last

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dynamic_image }
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
        format.xml  { render :xml => @dynamic_image.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dynamic_images/1
  # PUT /dynamic_images/1.xml
  def update
    @dynamic_image = DynamicImage.find(params[:id])

    respond_to do |format|
      if @dynamic_image.update_attributes(params[:dynamic_image])
        format.html { redirect_to(@dynamic_image, :notice => 'Dynamic image was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dynamic_image.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dynamic_images/1
  # DELETE /dynamic_images/1.xml
  def destroy
    @dynamic_image = DynamicImage.find(params[:id])
    @dynamic_image.destroy

    respond_to do |format|
      format.html { redirect_to(dynamic_images_url) }
      format.xml  { head :ok }
    end
  end
end

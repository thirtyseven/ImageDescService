class ImagesController < ApplicationController

  # GET /images
  # GET /images.xml
  def index
    @images = Image.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @images }
    end
  end

  # GET /images/1
  # GET /images/1.xml
  def show
    @image = Image.find(params[:id])
    @last_desc = @image.descriptions.last

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @library }
    end
  end

  # POST /images.xml
  # POST /images.json
  def create
    @library = Library.find(params[:image]['library_id'])

    @image = Image.new(params[:image])
    @image.id = SecureRandom.random_number(900000000)

=begin
    @image = @library.images.create(params[:image])
    @image.id = SecureRandom.random_number(1000000)
=end

    respond_to do |format|
      if @image.save
        format.xml  { render :xml => @image, :status => :created, :location => @image }
        format.json  { render :json => @image, :status => :created, :location => @image }
      else
        format.xml  { render :xml => @image.errors, :status => :unprocessable_entity }
        format.json  { render :json => @image.errors, :status => :unprocessable_entity }
      end
    end
  end
end

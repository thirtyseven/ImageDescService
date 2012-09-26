class DynamicDescriptionsController < ApplicationController
  before_filter :authenticate_user!
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
    book = load_book
    if params[:dynamic_description] && params[:dynamic_description][:dynamic_image_id]
      @dynamic_image = DynamicImage.where(:id => params[:dynamic_description][:dynamic_image_id]).first
      book = @dynamic_image.book if @dynamic_image
      @dynamic_description = @dynamic_image.dynamic_descriptions.create(params[:dynamic_description].merge({:book_id => book.id, :submitter => current_user.username})) if params[:dynamic_description] && params[:dynamic_description].is_a?(Hash)
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
        format.html { render :partial => 'dynamic_images/show_history_fragment', :locals => {:descriptions => [@dynamic_description] }}
        format.html { redirect_to(@dynamic_description, :notice => 'Dynamic description was successfully created.') }
        format.xml  { render :xml => @dynamic_description, :status => :created, :location => @dynamic_description }
        format.json  { render :json => {:body => render_to_string(:partial => 'dynamic_images/show_history_fragment.html.erb', :locals => {:descriptions => [@dynamic_description] })}, :callback => params[:callback]}
      else
        @book_id = book.id
        @image_location = params[:image_location]
        format.html { render :action => "new" }
        format.xml  { render :xml => @dynamic_description.errors, :status => :non_authoritative_information }
        format.json  { render :json => @dynamic_description.errors.full_messages, :callback => params[:callback], :status => 400 }
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
  
  def search 
    search_term = params['search']['term']
    
    @results = DynamicDescription.tire.search(:per_page => 3, :page => (params[:page] || 1)) do
      
      query do
        boolean do
          must   { string search_term }
          must   { term :is_last_approved, '1' }
        end
      end
    end

    @dynamic_description_hash = DynamicDescription.where(:id => @results.map(&:id)).all.inject({}){|acc, desc| acc[desc.id] = desc; acc}
  end
end

class DescriptionsController < ApplicationController
  def create
    @image = Image.find(params[:image_id])
    @description = @image.descriptions.create(params[:description])
    redirect_to image_path(@image)
  end

  def destroy
    @image = Image.find(params[:image_id])
    @description = @image.descriptions.find(params[:id])
    @description.destroy
    redirect_to image_path(@image)
  end
       
end

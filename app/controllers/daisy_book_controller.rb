require 'zip/zipfilesystem'

class DaisyBookController < ApplicationController
  def upload
  end

  def edit
    book = params[:book]
    if !book
      flash[:alert] = "Must specify a book file to process"
      redirect_to :action => 'upload'
      return
    end
    
    file = File.new( book.path )
    if !valid_daisy_zip?(file)
      flash[:alert] = "Uploaded file must be a valid Daisy (zip) file"
      redirect_to :action => 'upload'
      return
    end
  end

private
  def valid_daisy_zip?(file)
    begin
      Zip::ZipFile.open(file) do |zipfile|
        zipfile.get_entry 'dtbook-2005-3.dtd'
      end
    rescue
      return false
    end
    
    return true
  end
end

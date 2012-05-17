class DynamicImage < ActiveRecord::Base
  validates_presence_of :book_id
  validates :image_location,  :presence => true, :length => { :maximum => 255 }
  
  PAPERCLIP_STYLES = { :medium => "600x450>", :thumb => "200x150>" }
  if ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY'] && ENV['POET_ASSET_BUCKET']
    has_attached_file :physical_file, :styles => PAPERCLIP_STYLES, :storage => :aws, :s3_credentials => {:access_key_id => ENV['AWS_ACCESS_KEY_ID'], :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']}, :bucket => ENV['POET_ASSET_BUCKET'], :path => :path_by_book
  else
    has_attached_file :physical_file, :styles => PAPERCLIP_STYLES, :path => :tmp_path_by_book
  end

  belongs_to :book
  has_many :dynamic_descriptions
  
  def best_description
    return dynamic_descriptions.last
  end
  
  def image_source(host)
    return "#{host}/#{book.uid}/original/#{image_location}"
  end

  def thumb_source(host)
    return "#{host}/#{book.uid}/thumb/#{image_location}"
  end

  def medium_source(host)
    return "#{host}/#{book.uid}/medium/#{image_location}"
  end

  private

  def tmp_path_by_book
    "tmp/#{book.uid}/:style/#{image_location}"
  end
  
  def path_by_book
    "#{book.uid}/:style/#{image_location}"
  end
end

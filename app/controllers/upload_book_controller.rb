require 'fileutils'
require 'nokogiri'
require 'tempfile'
include DaisyUtils, UnzipUtils
include ActionView::Helpers::NumberHelper


class NoImageDescriptions < Exception
end

class NonDaisyXMLException < Exception
end

class MissingBookUIDException < Exception
end

class ShowAlertAndGoBack < Exception
  def initialize(message)
    @message = message
  end

  attr_reader :message
end

class UploadBookController < ApplicationController
  before_filter :authenticate_user!

  ROOT_XPATH = "/xmlns:dtbook"
  include RepositoryChooser

  def initialize
    super
    @repository = RepositoryChooser.choose
  end

  def submit

    #init session vars
    session[:book_id] = nil
    session[:content] = nil
    session[:daisy_directory] = nil



    book = params[:book]
    password = params[:password]
    if !book
      flash[:alert] = "Must specify a book file to process"
      redirect_to :action => 'upload'
      return
    end

    unless password.blank?
      begin
        Zip::Archive.decrypt(book.path, password)
      rescue Zip::Error => e
        logger.info "#{e.class}: #{e.message}"
        if e.message.include?("Wrong password")
          logger.info "#{request.remote_addr} Invalid Password for encyrpted zip"
          flash[:alert] = "Please check your password and re-enter"
        else
          logger.info "#{request.remote_addr} Other problem with encrypted zip"
          flash[:alert] = "There is a problem with this zip file"
        end
        redirect_to :action => 'upload'
        return
      end
    end

    if !valid_daisy_zip?(book.path)
      redirect_to :action => 'upload'
      return
    end

    begin
      daisy_directory = accept_book(book.path)
      xml = get_xml_from_dir daisy_directory
      doc = Nokogiri::XML xml
      @book_uid = extract_book_uid(doc)
      doc = nil
      xml = nil

      pid = fork do
        begin
          @repository.store_file(book.path, @book_uid, @book_uid + ".zip", nil)
          job = S3UnzippingJob.new(@book_uid, request.host_with_port, form_authenticity_token, @repository, current_library)
          Delayed::Job.enqueue(job)

          # hack for testing
          if (Rails.env.test?)
            Delayed::Worker.new.work_off
          end

        rescue AWS::Errors::Base => e
          logger.info "S3 Problem uploading book to S3 for book #{@book_uid}"
          logger.info "#{e.class}: #{e.message}"
          logger.info "Line #{e.line}, Column #{e.column}, Code #{e.code}"
          flash[:alert] = "There was a problem uploading"
          redirect_to :action => 'upload'
          return
        rescue Exception => e
          logger.info "Unknown problem uploading book to S3 for book #{@book_uid}"
          logger.info "#{e.class}: #{e.message}"
          logger.info e.backtrace.join("\n")
          $stderr.puts e
          flash[:alert] = "There was a problem uploading"
          redirect_to :action => 'upload'
          return
        end
      end
      Process.detach(pid)

      render 'display_uid'

    rescue Zip::Error => e
      logger.info "#{e.class}: #{e.message}"
      if e.message.include?("File encrypted")
        logger.info "#{request.remote_addr} Password needed for zip"
        flash[:alert] = "Please enter a password for this book"
      else
        logger.info "#{request.remote_addr} Other problem with zip"
        flash[:alert] = "There is a problem with this zip file"
      end

      redirect_to :action => 'upload'
      return
    end
  end

private
  def get_xml_from_dir daisy_directory = nil
    book_directory = daisy_directory || session[:daisy_directory]
    contents_filename = get_daisy_contents_xml_name(book_directory)
    File.read(contents_filename)
  end

  def get_daisy_contents_xml_name(book_directory)
    return Dir.glob(File.join(book_directory, '*.xml'))[0]
  end


end
class RepositoryController < ApplicationController
  before_filter :authenticate_user!

  require 's3_repository'


  def cleanup
    job = S3CleanupJob.new
    Delayed::Job.enqueue(job)
  end

  def expire_cached
    job = S3RemoveCachedHTMLJob.new
    Delayed::Job.enqueue(job)
  end

end
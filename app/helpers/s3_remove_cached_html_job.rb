class S3RemoveCachedHTMLJob
  require 's3_repository'

  def enqueue(job)

  end

  def perform
    S3Repository.remove_cached_htmls
  end
end
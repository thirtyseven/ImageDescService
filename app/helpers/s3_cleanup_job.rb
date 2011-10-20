class S3CleanupJob
  require 's3_repository'

  def enqueue(job)

  end

  def perform
    S3Repository.cleanup(ENV['POET_S3_EXPIRE_DAYS'].to_f)
  end

end
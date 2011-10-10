module RepositoryChooser
  require 'local_repository'
  require 's3_repository'

  def self.choose
    if (Rails.env.test? || ENV['POET_LOCAL_STORAGE_DIR'])
      return LocalRepository
    else
      return S3Repository
    end
  end
end
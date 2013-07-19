module RepositoryChooser
  require 'local_repository'
  require 's3_repository'

  def self.choose klass_name=nil
    if (Rails.env.test? || ENV['POET_LOCAL_STORAGE_DIR']) || (klass_name == LocalRepository.name)
      return LocalRepository
    else
      return S3Repository
    end
  end
end
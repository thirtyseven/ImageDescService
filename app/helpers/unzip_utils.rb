module UnzipUtils
  
  def accept_book(book_path)
    UnzipUtils.accept_book(book_path)
  end
  def unzip_to_temp(zipped_file)
    UnzipUtils.unzip_to_temp(zipped_file)
  end
  def self.accept_book(book_path)
    zip_directory = unzip_to_temp(book_path)
    top_level_entries = Dir.entries(zip_directory)
    top_level_entries.delete('.')
    top_level_entries.delete('..')
    if(top_level_entries.size == 1)
      book_directory = File.join(zip_directory, top_level_entries.first)
    else
      book_directory = zip_directory
    end

    copy_of_daisy_file = File.join(zip_directory, "Daisy.zip")
    FileUtils.cp(book_path, copy_of_daisy_file)

    return zip_directory, book_directory, copy_of_daisy_file
  end

  def self.unzip_to_temp(zipped_file)
    dir = Dir.mktmpdir
    Zip::Archive.open(zipped_file) do |zipfile|
      zipfile.each do |entry|
        destination = File.join(dir, entry.name)
        if entry.directory?
          FileUtils.mkdir_p(destination)
        else
          dirname = File.join(dir, File.dirname(entry.name))
          FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
          open(destination, 'wb') do |f|
            f << entry.read
          end
        end
      end
    end
    return dir
  end

end
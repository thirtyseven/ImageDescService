require "test/unit"

class EpubUtilsTest < Test::Unit::TestCase
  
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    #Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end

  def test_get_filenames_from_manifest
    bookDirectory = EpubUtils.get_epub_file_main_directory('features/fixtures/Magic_Tree_House__4__Pirates_Pas')
    filenames = EpubUtils.get_epub_book_xml_file_names(bookDirectory)
    
    Rails::logger.debug filenames.inspect
    
    assert_equal filenames.size, 13
  end
  
end

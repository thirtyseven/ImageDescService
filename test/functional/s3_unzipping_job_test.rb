require "test/unit"

class S3UnzippingJobTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @job = S3UnzippingJob.new("25")
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end

  def test_extract_title
    xml = File.read('features/fixtures/BookXMLWithImagesWithoutGroups.xml')
    doc = Nokogiri::XML xml
    book_title = @job.extract_optional_book_title(doc)
    assert_equal 'Outline of U.S. History', book_title
  end

  def test_extract_missing_title
    xml_without_title = File.read('features/fixtures/NotValidBook.xml')
    doc = Nokogiri::XML xml_without_title
    assert_nil @job.extract_optional_book_title(doc)
  end

  def test_extract_isbn
    xml = File.read('features/fixtures/Sample.opf')
    doc = Nokogiri::XML xml
    isbn = @job.extract_optional_isbn(doc)
    assert_equal '9780078913280', isbn
  end
end
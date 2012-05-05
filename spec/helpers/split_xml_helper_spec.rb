require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the SplitXmlHelper. For example:
#
# describe SplitXmlHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe SplitXmlHelper do
  it "should split at each level when we have a relatively low max limit of images" do
    xml_splitting, image_limit = load_test_xml 3
    segments = parse_and_segment xml_splitting, image_limit
    
    segments.each do |seg|
      seg_doc = Nokogiri::XML seg
      seg_num_images = seg_doc.css('img').size
      p "ESH: have a seg= with #{seg_num_images} images"
    end
    
    segments.size.should eq 3
  end

  it "should not split at each level when we have a relatively high max limit of images" do
    xml_splitting, image_limit = load_test_xml 1
    segments = parse_and_segment xml_splitting, image_limit
    
    segments.size.should eq 1
  end
  
  def load_test_xml target_chunks
    xml_splitting = File.read('features/fixtures/TestOfSplittingXml.xml')
    doc = Nokogiri::XML xml_splitting
    num_images = doc.css('img').size
    
    # Shoot for about target_chunks chunks of images
    image_limit = num_images/target_chunks
    [xml_splitting, image_limit]
  end
  
  def parse_and_segment xml_splitting, image_limit
    # Create our parser
    splitter = DTBookSplitter.new(image_limit)
    parser = Nokogiri::XML::SAX::Parser.new(splitter)

    # Send some XML to the parser
    parser.parse(xml_splitting)
    splitter.segments   #array of fully formed xml strings that each represent a broken up piece of the whole xml
  end
end

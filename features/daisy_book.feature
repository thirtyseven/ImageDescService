Feature: Daisy Book

	As a normal user,
	I want to be able to upload a daisy book (zip file)
	So that I can edit the image descriptions
	
	Scenario: Upload page should have the necessary content
		When I go to the daisy upload page
		Then I should see "unencrypted Daisy book (zip) file"

	Scenario: Hitting upload with no book selected
		When I go to the daisy upload page
		And I press "Upload"
		Then I should be on the daisy upload page
		And I should see "Must specify a book file to process"
		
	Scenario: Uploading a non-zip file
		When I go to the daisy upload page
		And I attach the file "features/fixtures/NonXMLFile" to "book"
		And I press "Upload"
		Then I should be on the daisy upload page
		And I should see "Uploaded file must be a valid Daisy (zip) file"
	
	Scenario: Uploading a non-Daisy zip file
		When I go to the daisy upload page
		And I attach the file "features/fixtures/NonDaisyZip.zip" to "book"
		And I press "Upload"
		Then I should be on the daisy upload page
		And I should see "Uploaded file must be a valid Daisy (zip) file"
		
	Scenario: Uploading a valid Daisy zip file
		When I go to the daisy upload page
		And I attach the file "features/fixtures/DaisyZipBookUnencrypted.zip" to "book"
		And I press "Upload"
		Then I should be on the description editing page
		And there should be frames
		And the xpath "//frameset/frame[@name='side_bar']" should exist
		And the xpath "//frameset/frameset/frame[@name='top_bar']" should exist
		And the xpath "//frameset/frameset/frame[@name='content']" should exist
		When I go to the content page
		Then I should see "John Gallaugher"
		When I go to the sidebar page
		Then the xpath "//img" should exist
		
	# TODO: Need tests for non-bookshare Daisy books:
	#    - Multiple XML content files?
	#    - Different case of XML/xml files
	#    - XML files not at the top level?
	#	 - Non-JPEG images
	
	Scenario: Downloading an XML file with descriptions
		When the first description for the image "images/fwk-gallaugher-fig01_001.jpg" in book "_id2244343" with title "Information Systems: A Manager’s Guide to Harnessing Technology" is "Prodnote from database"
		And I go to the daisy upload page
		And I attach the file "features/fixtures/DaisyZipBookUnencrypted.zip" to "book"
		And I press "Upload"
		And I go to the header panel
		And I press "Download XML"
		Then the response should be xml
		And the xpath "//dtbook" should exist
		And the xpath "//img" should exist
		And the xpath "//imggroup" should exist
		And the xpath "//prodnote" should exist
		And the xpath "//imggroup/prodnote[@id='pnid_img_000003']" should exist
		And the xpath "//imggroup/prodnote[@id='pnid_img_000003']" should be "Prodnote from database"
		
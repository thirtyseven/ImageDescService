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
		
	Scenario: Uploading a valid Daisy zip file with images
		When I go to the daisy upload page
		And I attach the file "features/fixtures/DaisyZipBookUnencrypted.zip" to "book"
		And I press "Upload"
		Then I should be on the description editing page
		And there should be frames
		And the xpath "//frameset/frame[@name='top_bar']" should exist
		And the xpath "//frameset/frameset/frame[@name='side_bar']" should exist
		And the xpath "//frameset/frameset/frame[@name='content']" should exist
		When I go to the content page
		Then I should see "John Gallaugher"
		When I go to the sidebar page
		Then the xpath "//img" should exist
		
	Scenario: Uploading a valid non-Bookshare Daisy zip file with no DTD file
		When I go to the daisy upload page
		And I attach the file "features/fixtures/DaisyZipBookWithoutDTD.zip" to "book"
		And I press "Upload"
		Then I should be on the description editing page

	Scenario: Uploading a Bookshare Daisy zip file with missing images directory
		When I go to the daisy upload page
		And I attach the file "features/fixtures/DaisyZipBookWithMissingImages.zip" to "book"
		And I press "Upload"
		Then I should be on the description editing page
		When I go to the header panel
		Then the xpath "//input" should exist
		When I go to the sidebar page
		Then the xpath "//img" should exist

	Scenario: Uploading a valid non-Bookshare Daisy zip file with all files in a subdirectory
		When I go to the daisy upload page
		And I attach the file "features/fixtures/DaisyZipBookWithTopLevelSubdirectory.zip" to "book"
		And I press "Upload"
		Then I should be on the description editing page
		And I go to the header panel
		And I press "Save As..."
		Then the response should be a zip file

	Scenario: Uploading an Internet Archive (slightly invalid) Daisy zip file
		When I go to the daisy upload page
		And I attach the file "features/fixtures/DaisyZipBookWithSlightlyInvalidEntries.zip" to "book"
		And I press "Upload"
		Then I should be on the description editing page
		And I go to the header panel
		And I press "Save As..."
		Then the response should be a zip file

	# TODO: Need tests for more non-bookshare Daisy books:
	#    - Multiple XML content files?
	#    - Different case of XML/xml files
	#	 - Non-JPEG images
	
	Scenario: Downloading an XML file with descriptions
		When the first description for the image "images/fwk-gallaugher-fig01_001.jpg" in book "_id2244343" with title "Information Systems: A Manager’s Guide to Harnessing Technology" is "Prodnote from database"
		And I go to the daisy upload page
		And I attach the file "features/fixtures/DaisyZipBookUnencrypted.zip" to "book"
		And I press "Upload"
		And I go to the raw xml download page
		Then the response should be xml
		And the xpath "//dtbook" should exist
		And the xpath "//img" should exist
		And the xpath "//imggroup" should exist
		And the xpath "//prodnote" should exist
		And the xpath "//imggroup/prodnote[@id='pnid_img_000003']" should exist
		And the xpath "//imggroup/prodnote[@id='pnid_img_000003']" should be "Prodnote from database"

	Scenario: Downloading a Daisy book with descriptions
		When the first description for the image "images/fwk-gallaugher-fig01_001.jpg" in book "_id2244343" with title "Information Systems: A Manager’s Guide to Harnessing Technology" is "Prodnote from database"
		And I go to the daisy upload page
		And I attach the file "features/fixtures/DaisyZipBookUnencrypted.zip" to "book"
		And I press "Upload"
		And I go to the header panel
		And I press "Save As..."
		Then the response should be a zip file
		
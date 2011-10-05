Feature: Daisy Book

	As a normal user,
	I want to be able to upload a daisy book (zip file)
	So that I can edit the image descriptions
	
	Scenario: Upload page should have the necessary content
        Given I am a user named "john" with an email "john.smith@dot.com" and password "123456" and username "johns"
        When I sign in as "john.smith@dot.com/123456"
		When I go to the daisy upload page
		Then I should see "DAISY Book"

	Scenario: Hitting upload with no book selected
        Given I am a user named "john" with an email "john.smith@dot.com" and password "123456" and username "johns"
        When I sign in as "john.smith@dot.com/123456"
		When I go to the daisy upload page
		And I press "Upload"
		Then I should be on the daisy upload page
		And I should see "Must specify a book file to process"
		
	Scenario: Uploading a non-zip file
        Given I am a user named "john" with an email "john.smith@dot.com" and password "123456" and username "johns"
        When I sign in as "john.smith@dot.com/123456"
		When I go to the daisy upload page
		And I attach the file "features/fixtures/NonXMLFile" to "book"
		And I press "Upload"
		Then I should be on the daisy upload page
		And I should see "Uploaded file must be a valid Daisy (zip) file"
	
	Scenario: Uploading a non-Daisy zip file
        Given I am a user named "john" with an email "john.smith@dot.com" and password "123456" and username "johns"
        When I sign in as "john.smith@dot.com/123456"
		When I go to the daisy upload page
		And I attach the file "features/fixtures/NonDaisyZip.zip" to "book"
		And I press "Upload"
		Then I should be on the daisy upload page
		And I should see "Uploaded file must be a valid Daisy (zip) file"
		
	Scenario: Uploading a valid non-Bookshare Daisy zip file with no DTD file
        Given I am a user named "john" with an email "john.smith@dot.com" and password "123456" and username "johns"
        When I sign in as "john.smith@dot.com/123456"
		When I go to the daisy upload page
		And I attach the file "features/fixtures/DaisyZipBookWithoutDTD.zip" to "book"
		And I press "Upload"
		Then I should be on the upload for edit success page

	Scenario: Uploading a valid Daisy zip file with images
        Given I am a user named "john" with an email "john.smith@dot.com" and password "123456" and username "johns"
        When I sign in as "john.smith@dot.com/123456"
		When I go to the daisy upload page
		And I attach the file "features/fixtures/DaisyZipBookUnencrypted.zip" to "book"
		And I press "Upload"
		Then I should be on the upload for edit success page
		Then I should see "_id2244343"

	Scenario: Uploading a Bookshare Daisy zip file with missing images directory
        Given I am a user named "john" with an email "john.smith@dot.com" and password "123456" and username "johns"
        When I sign in as "john.smith@dot.com/123456"
		When I go to the daisy upload page
		And I attach the file "features/fixtures/DaisyZipBookWithMissingImages.zip" to "book"
		And I press "Upload"
		Then I should be on the upload for edit success page

#    Scenario: Editing a valid Daisy zip file with images
#		When I go to the home page
#		And I fill in "book_uid" with "_id2244343"
#		And I press "Edit"
#		Then I should be on the description editing page
#		And there should be frames
#		And the xpath "//frameset/frame[@name='side_bar']" should exist
#		And the xpath "//frameset/frame[@name='content']" should exist
#		When I go to the content page
#		Then I should see "John Gallaugher"
#		When I go to the sidebar page
#		Then the xpath "//img" should exist

	Scenario: Downloading an XML file with an image that is in the db but has no descriptions (IMG-100)
		When the image "images/fwk-gallaugher-fig01_001.jpg" in book "_id2244343" with title "Information Systems: A Manager’s Guide to Harnessing Technology" exists but has no description
		And I go to the daisy process page
		And I attach the file "features/fixtures/DaisyZipBookUnencrypted.zip" to "book"
		And I press "Process"
		And I go to the raw xml download page
		Then the response should be html
		# NOTE: Should look for error message, but we end up back on the 
		# edit page, and the edit page doesn't display alerts

	Scenario: Downloading a valid non-Bookshare Daisy zip file with all files in a subdirectory
		When the first description for the image "image1.jpg" in book "AUTO-UID-4767990567747899000" with title "ARE YOU READY?" is "Prodnote from database"
		And I go to the daisy process page
		And I attach the file "features/fixtures/DaisyZipBookWithTopLevelSubdirectory.zip" to "book"
		And I press "Process"
		Then the response should be a zip file

	Scenario: Downloading an Internet Archive (slightly invalid) Daisy zip file (and no images)
		And I go to the daisy process page
		And I attach the file "features/fixtures/DaisyZipBookWithSlightlyInvalidEntries.zip" to "book"
		And I press "Process"
		Then the response should be html
		And I should see "no image descriptions available for this book"

	Scenario: Downloading a Daisy zip file with an image that has no src attribute
		When the first description for the image "images/image001.jpg" in book "en-us-20100226091725" with title "CK-12 Biology I" is "Prodnote from database"
		And I go to the daisy process page
		And I attach the file "features/fixtures/DaisyZipBookWithMissingSrcAttribute.zip" to "book"
		And I press "Process"
		Then the response should be a zip file

	Scenario: Downloading an XML file with descriptions
       Given I am a user named "john" with an email "john.smith@dot.com" and password "123456" and username "johns"
        When I sign in as "john.smith@dot.com/123456"
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

	Scenario: Downloading a Daisy book with no descriptions
		And I go to the daisy process page
		And I attach the file "features/fixtures/DaisyZipBookUnencrypted.zip" to "book"
		And I press "Process"
		And dump the page to stderr
		And I should see "no image descriptions available for this book"
		
	Scenario: Downloading a Daisy book with descriptions
		When the first description for the image "images/fwk-gallaugher-fig01_001.jpg" in book "_id2244343" with title "Information Systems: A Manager’s Guide to Harnessing Technology" is "Prodnote from database"
		And I go to the daisy process page
		And I attach the file "features/fixtures/DaisyZipBookUnencrypted.zip" to "book"
		And I press "Process"
		Then the response should be a zip file
		
	Scenario: Downloading a Daisy zip file with unrecognized prodnotes and image not directly inside group
		When the first description for the image "images/cover.jpg" in book "_id2244343" with title "Information Systems: A Manager’s Guide to Harnessing Technology" is "Prodnote from database"
		And I go to the daisy process page
		And I attach the file "features/fixtures/DaisyZipBookImageNotDirectChildOfGroup.zip" to "book"
		And I press "Process"
		Then the response should be a zip file
		And I go to the raw xml download page
		Then the response should be xml
		And the xpath "//imggroup" should exist
		And the xpath "//imggroup//prodnote[@id='p510-001']" should exist
		And the xpath "//imggroup//prodnote[@id='pnid_img_000001']" should exist
	
	# TODO: Need tests for more non-bookshare Daisy books:
	#    - Multiple XML content files?
	#    - Different case of XML/xml files
	#	 - Non-JPEG images
	
		
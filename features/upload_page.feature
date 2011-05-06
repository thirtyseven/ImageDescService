Feature: Upload Page

	As a normal user,
	I want to be able to upload a daisy xml book
	So that I can get back a copy with embedded descriptions
	
	Scenario: Upload page should have the necessary content
		When I go to the upload page
		Then I should see "The file will be returned with all available image descriptions added."
		
	Scenario: Hitting upload with no book selected
		When I go to the upload page
		And I press "Upload"
		Then I should be on the upload page
		And I should see "Must specify a book file to process"
		
	Scenario: Uploading a non-XML book
		When I go to the upload page
		And I attach the file "features/fixtures/NonXMLFile" to "book"
		And I press "Upload"
		Then I should be on the upload page
		And I should see "Uploaded file must be a valid Daisy book XML content file"
		
	Scenario: Uploading an XML file that is not a valid book contents file
		When I go to the upload page
		And I attach the file "features/fixtures/NotValidBook.xml" to "book"
		And I press "Upload"
		Then I should be on the upload page
		And I should see "Uploaded file must be a valid Daisy book XML content file"
		
	Scenario: Uploading a book with no known images
		When I go to the upload page
		And I attach the file "features/fixtures/BookXMLWithImagesWithoutGroups.xml" to "book"
		And I press "Upload"
		Then the response should be xml
		# TODO: Should verify disposition (attachment) and filename
		And the xpath "//dtbook" should exist
		And the xpath "//img" should exist
		And the xpath "//prodnote" should not exist
		
	Scenario: Make sure an image description can be added to the database (directly)
		When the first description for the image "images/image001.jpg" in book "en-us-20100517111839" with title "Outline of U.S. History" is "Prodnote from database"
		And I go to the images list page
		Then I should see "images/image001.jpg"
		
	Scenario: Uploading a book with known images but no existing prodnotes
		When the first description for the image "images/image001.jpg" in book "en-us-20100517111839" with title "Outline of U.S. History" is "Prodnote from database"
		And I go to the upload page
		And I attach the file "features/fixtures/BookXMLWithImagesWithoutGroups.xml" to "book"
		And I press "Upload"
		Then the response should be xml
		# TODO: Should verify disposition (attachment) and filename
		And the xpath "//dtbook" should exist
		And the xpath "//img" should exist
		And the xpath "//imggroup" should exist
		And the xpath "//prodnote" should exist
		And the attribute "id" of "//prodnote" should be "pnid_mkme_0001" 
		And the xpath "//prodnote" should be "Prodnote from database"

	Scenario: Uploading a book with prodnotes added by our site earlier
		When the first description for the image "images/image001.jpg" in book "en-us-20100517111839" with title "Outline of U.S. History" is "Prodnote from database"
		And I go to the upload page
		And I attach the file "features/fixtures/BookXMLWithImagesWithOurProdnotes.xml" to "book"
		And I press "Upload"
		Then the response should be xml
		# TODO: Should verify disposition (attachment) and filename
		And the xpath "//imggroup/prodnote[@id='pnid_mkme_0001']" should exist
		And the xpath "//imggroup/prodnote[@id='pnid_mkme_0001']" should be "Prodnote from database"

	Scenario: Uploading a book with unrecognized prodnotes
		When the first description for the image "images/image001.jpg" in book "en-us-20100517111839" with title "Outline of U.S. History" is "Prodnote from database"
		And I go to the upload page
		And I attach the file "features/fixtures/BookXMLWithImagesWithUnrecognizedProdnotes.xml" to "book"
		And I press "Upload"
		Then I should see "Unable to update descriptions"
		And I should see "contained descriptions from other sources"

	Scenario: Uploading a book with out-of-date prodnotes added by our site earlier
		When the first description for the image "images/image001.jpg" in book "en-us-20100517111839" with title "Outline of U.S. History" is "Prodnote from database"
		And another description for the image "images/image001.jpg" in book "en-us-20100517111839" is "Revised description from database"
		And I go to the upload page
		And I attach the file "features/fixtures/BookXMLWithImagesWithOurProdnotes.xml" to "book"
		And I press "Upload"
		Then the response should be xml
		# TODO: Should verify disposition (attachment) and filename
		And the xpath "//imggroup/prodnote[@id='pnid_mkme_0001']" should exist
		And the xpath "//imggroup/prodnote[@id='pnid_mkme_0001']" should be "Revised description from database"


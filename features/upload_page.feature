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
		And I attach the file "spec/fixtures/NonXMLFile" to "book"
		And I press "Upload"
		Then I should be on the upload page
		And I should see "Uploaded file must be a valid Daisy book XML content file"
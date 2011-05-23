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
		

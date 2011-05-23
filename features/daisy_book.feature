Feature: Daisy Book

	As a normal user,
	I want to be able to upload a daisy book (zip file)
	So that I can edit the imgae descriptions
	
	Scenario: Upload page should have the necessary content
		When I go to the daisy upload page
		Then I should see "unencrypted Daisy book (zip) file"

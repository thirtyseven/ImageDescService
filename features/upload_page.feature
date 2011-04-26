Feature: Upload Page

	As a normal user,
	I want to be able to upload a daisy xml book
	So that I can get back a copy with embedded descriptions
	
	Scenario: Upload page should have the necessary content
		When I go to the upload page
		Then I should see "The file will be returned with all available image descriptions added."
		
		
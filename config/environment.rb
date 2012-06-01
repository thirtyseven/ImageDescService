# Load the rails application
require File.expand_path('../application', __FILE__)

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Initialize the rails application
DiagramRailsApp::Application.initialize!

Time::DATE_FORMATS[:poet_default] = "%b %d, %Y"
Time::DATE_FORMATS[:poet_default_dt] = "%b %d, %Y  %I:%M%p %Z"

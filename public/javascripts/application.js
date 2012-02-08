// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Create a way to toggle between DIVs

jQuery(function($) {
	function bookToggleOnElement(element) {
		var selectorForOnElement = $(element).attr('data-related-on');
	  return $(selectorForOnElement, $(element).parents());
	}
	function bookToggleOffElement(element) {
		var selectorForOffElement = $(element).attr('data-related-off');
	  return $(selectorForOffElement, $(element).parents());
	}
	
	$(".book-toggle").each(function() {
		if($(this).attr('checked')) {
			bookToggleOffElement(this).hide();
			bookToggleOnElement(this).show();
		}
		else {
			bookToggleOffElement(this).show();
			bookToggleOnElement(this).hide();
		}
   });
	
	$(".book-toggle")
		.click(function() {
			bookToggleOffElement(this).toggle();
			bookToggleOnElement(this).toggle();
		});
});
jQuery(function($) {
	// create a convenient toggleLoading function
	var toggleLoading = function() { $("#loading").toggle() };

  $(".book-link-ajax")
  	.bind("ajax:success", function(event, data, status, xhr) {
			var actionDiv = $(this).parents('.action');
			actionDiv.text("success");
			actionDiv.css('fontWeight', "bold");
	    actionDiv.css('color', "orange");
    }) 
  .bind("ajax:failure", function(event, data, status, xhr) {
			var actionDiv = $(this).parents('.action');
			actionDiv.text("failure");
			actionDiv.css('fontWeight', "bold");
	    actionDiv.css('color', "red");
    });
});
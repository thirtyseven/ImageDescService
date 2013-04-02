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

  function bookToggleOnElement(element) {
    var selectorForOnElement = $(element).attr('data-related-on');
    return $(selectorForOnElement, $(element).parents());
  }
  function bookToggleOffElement(element) {
    var selectorForOffElement = $(element).attr('data-related-off');
    return $(selectorForOffElement, $(element).parents());
  }
  function htmlDecode(value){ 
    return $('<div/>').html(value).text(); 
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

  $('.convert-to-iframe').each(function(index, item) {
    $frame = $('<iframe width="100%" height="100" scrolling="yes"/>');
    $($frame).insertAfter(item).contents().find('body').append(htmlDecode($(item).html()));
    $(item).remove();
  });


});
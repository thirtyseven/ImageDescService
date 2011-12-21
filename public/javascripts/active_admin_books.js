jQuery(function($) {
  // create a convenient toggleLoading function
  var toggleLoading = function() { $("#loading").toggle() };

  $(".book-link-ajax")
     .bind("ajax:success", function(event, data, status, xhr) {
       alert( "success!");
     }) 
     .bind("ajax:failure", function(event, data, status, xhr) {
       alert( "failure!");
     });
});
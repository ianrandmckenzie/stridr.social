// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/
document.addEventListener("turbolinks:load", function() {

  if ($("body").is("#social_page_show")) {
    $('.pagination').css('display', 'none');
    var pageNumber = 1;
    var path = window.location.pathname;
    window.loadFeed = function () {
        pageNumber++;
      $.get('?page=' + pageNumber, function (data) {
        $(data).appendTo($("#social_page_show #card-wrapper"));
        if (data === ''){
          $('.pagination').html("That's all, folks!");
          $('.pagination').css("display", "block");
          $('.loading').hide();
        }
      });
    };

    $(window).scroll(function () {
       if ($(window).scrollTop() >= $(document).height() - $(window).height()) {
          loadFeed();
       }
    });
  }
});

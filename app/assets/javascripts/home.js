document.addEventListener("turbolinks:load", function() {

  if ($("body").is("#home_index")) {
    $('.pagination').css('display', 'none');
    var pageNumber = 1;
    var path = window.location.pathname;
    window.loadFeed = function () {
        pageNumber++;
      $.get('?page=' + pageNumber, function (data) {
        $(data).appendTo($("#home_index #card-wrapper"));
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

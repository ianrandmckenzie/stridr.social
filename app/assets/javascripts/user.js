document.addEventListener("turbolinks:load", function() {

    refreshPartial();
    setInterval(refreshPartial, 3000);

    function refreshPartial() {
      $.ajax({
        url: "user/loading_card"
     });
      if ($("#loading_message").text() == "Recent Posts Found!"){
        $("#loading_card").hide();
      } else {
        $("#loading_card").show();
      }
    }

  if ($("body").is("#user_show") || $("body").is("#user_feed") || $("body").is("#user_difference") || $("body").is("#user_match")) {
    $('.pagination').css('display', 'none');
    var pageNumber = 1;
    var path = window.location.pathname;
    window.loadFeed = function () {
        pageNumber++;
      $.get('?page=' + pageNumber, function (data) {
        $(data).appendTo($("#user_show #card-wrapper"));
        $(data).appendTo($("#user_feed #card-wrapper"));
        $(data).appendTo($("#user_difference #card-wrapper"));
        $(data).appendTo($("#user_match #card-wrapper"));
        if (data === ''){
          $('.pagination').html("That's all, folks!");
          $('.pagination').css("display", "block");
          $('.loading').hide();
        }
      });
    };

    var loaded = false;
    var loading = false;

    $(window).scroll(function () {
       if ($(window).scrollTop() >= $(document).height() - $(window).height()) {
          loadFeed();
       }
    });
  }
});

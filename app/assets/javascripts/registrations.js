document.addEventListener("turbolinks:load", function() {
  var title;
  $(".settings-tab-button").click(function(){
    $(".settings-tab-button").removeClass("active");
    $(this).toggleClass("active");
    title = $(this).find(".tab-title").html();
    title = title.toLowerCase();
    title = "#" + title;

    $(".settings-box-bottom").hide();
    $(".settings-box").hide();
    $(title).show();
    if(title === "#account"){
      $(".settings-box-bottom").show();
    }
  })
});

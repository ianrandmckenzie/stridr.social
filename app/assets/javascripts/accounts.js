document.addEventListener("turbolinks:load", function() {
  if ($("body").is("#accounts_customize")) {
    setInterval(refreshPartial, 3000);

    function refreshPartial() {
      $.ajax({
        url: "table"
     })
    }
  }
});

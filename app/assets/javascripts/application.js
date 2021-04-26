// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require bootstrap
//= require turbolinks
//= require navigation
//= require social-share-button
//= require_tree .


document.addEventListener("turbolinks:load", function() {

  $(".flash .fa-times").click(function(){
    $(this).parent().parent().hide();
  });

  // For bootstraps popover for desktop navigation.
    $(function(){
      $('[rel="account_popover"]').popover({
          container: 'body',
          html: true,
          content: function () {
              var clone = $($(this).data('popover-content')).clone(true).removeClass('hide');
              return clone;
          }
      }).click(function(e) {
          e.preventDefault();
      });
    });

  $(function(){
    $('[rel="settings_popover"]').popover({
        container: 'body',
        html: true,
        content: function () {
            var clone = $($(this).data('popover-content')).clone(true).removeClass('hide');
            return clone;
        }
    }).click(function(e) {
        e.preventDefault();
    });
  });




  var cards = $(".card-container");

  $(".toggle-icon").click(function(){
    $(this).toggleClass("account-nonactive");

    if ($(this).hasClass("toggle-icon-facebook")) {
      $(".card-container-facebook").toggle();
    }
    else if ($(this).hasClass("toggle-icon-youtube")) {
      $(".card-container-youtube").toggle();
    }
    else if ($(this).hasClass("toggle-icon-twitter")) {
      $(".card-container-twitter").toggle();
    }
    else if ($(this).hasClass("toggle-icon-tumblr")) {
      $(".card-container-tumblr").toggle();
    }
    else if ($(this).hasClass("toggle-icon-pinterest")) {
      $(".card-container-pinterest").toggle();
    }
    else if ($(this).hasClass("toggle-icon-reddit")) {
      $(".card-container-reddit").toggle();
    }
    else if ($(this).hasClass("toggle-icon-spotify")) {
      $(".card-container-spotify").toggle();
    }
    else if ($(this).hasClass("toggle-icon-instagram")) {
      $(".card-container-instagram").toggle();
    }
    else if ($(this).hasClass("toggle-icon-twitch")) {
      $(".card-container-twitch").toggle();
    }
    else if ($(this).hasClass("toggle-icon-deviantart")) {
      $(".card-container-deviantart").toggle();
    } else {
    }
  });

});

// Toggle Navigation
function toggleNav(closed) {
  if (closed && window.matchMedia('(min-width: 700px)').matches) {
  	document.getElementById("mySidenav").style.width = "40%";
  	document.getElementById("card-wrapper").style.opacity = "0.55";
    $("#mobile-nav-icon").attr("onclick", "toggleNav(false)");
    closed = false;
    return;
  } else if (closed) {
  	document.getElementById("mySidenav").style.width = "100%";
  	document.getElementById("card-wrapper").style.opacity = "0.55";
    $("#mobile-nav-icon").attr("onclick", "toggleNav(false)");
    closed = false;
    return;
  }
  if (closed === false){
  	document.getElementById("mySidenav").style.width = "0";
  	document.getElementById("card-wrapper").style.opacity = "1";
    $("#mobile-nav-icon").attr("onclick", "toggleNav(true)");
  }
}

function showDesktopToggles() {
  var li = document.getElementById("desktop-toggles");
  if (li.style.display == "block") {
    li.style.display = "none";
  } else {
    li.style.display = "block";
  }
}

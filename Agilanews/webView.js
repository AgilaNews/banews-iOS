window.onload =  function(){
    var elems = document.getElementsByClassName("ready-to-load");
    for (var i = 0; i < elems.length; i++) {
        var elem = elems[i];
        console.info(elem);
        if (elem.getAttribute("data-src")) {
            elem.setAttribute("src", elem.getAttribute("data-src"));
        }
    }
};
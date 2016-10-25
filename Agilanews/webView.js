//window.onload =  function(){
//    var elems = document.getElementsByClassName("ready-to-load");
//    for (var i = 0; i < elems.length; i++) {
//        var elem = elems[i];
//        console.info(elem);
//        if (elem.getAttribute("data-src")) {
//            elem.setAttribute("src", elem.getAttribute("data-src"));
//        }
//    }
//};
//
//function log(message)
//{
//    alert(message);
//}
//
//
//window.onerror = function(error){
//    log("error: " + error)
//}

/*这段代码是固定的，必须要放到js中*/
function setupWebViewJavascriptBridge(callback)
{
    if (window.WebViewJavascriptBridge) {
        return callback(WebViewJavascriptBridge);
    }
    if (window.WVJBCallbacks) {
        return window.WVJBCallbacks.push(callback);
    }
    window.WVJBCallbacks = [callback];
    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';
    document.documentElement.appendChild(WVJBIframe);
    setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
}

var elems = null;

/*与OC交互的所有JS方法都要放在此处注册*/
setupWebViewJavascriptBridge(function(bridge) {
    if (elems != null) {
        return;
    }
    elems = document.getElementsByClassName("ready-to-load");
    for (var i = 0; i < elems.length; i++) {
        var elem = elems[i];
        var url = elem.getAttribute("data-src");
        if (url == null || url == undefined || url == '') {
            continue;
        }
        var type = elem.getAttribute("img-type");
        if (type == 'video') {
            elem.onclick = function() {
                var type = this.getAttribute("img-type");
                var videoid = this.getAttribute("videoid");
                var index = this.getAttribute("index");
                if(videoid == null || videoid == undefined || videoid == '') {
                    return;
                }
                bridge.callHandler('ObjcCallback', {type:type, index:index, videoid:videoid});
            }
        }
        bridge.callHandler('ObjcCallback', {url:url, id:i},
        function(response) {
            var local_index = response.id;
            if (local_index < elems.length && local_index >= 0) {
                var imageSrc = response.path;
                if (imageSrc != null && imageSrc != undefined && imageSrc != '') {
                    elems[local_index].setAttribute("src", imageSrc);
                }
            }
        });
    }
})
//bridge.registerHandler('testJavascriptHandler', function(data, responseCallback) {
//                    log('ObjC called testJavascriptHandler with', data)
//                    var responseData = { 'Javascript Says':'Right back atcha!' }
//                    log('JS responding with', responseData)
//                    responseCallback(responseData)
//                    })





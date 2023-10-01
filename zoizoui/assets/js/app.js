// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page


let Hooks = {};

Hooks.FooButton = {
    mounted() {
        this.el.addEventListener('mousedown', () => {
            this.pushEvent(this.el.dataset.buttonid + '_pressed');
        });
        this.el.addEventListener('mouseup', () => {
            this.pushEvent(this.el.dataset.buttonid + '_released');
        });
        this.el.addEventListener('touchstart', (e) => {
            e.preventDefault();
            this.pushEvent(this.el.dataset.buttonid + '_pressed');
        });
        this.el.addEventListener('touchend', (e) => {
            e.preventDefault();
            this.pushEvent(this.el.dataset.buttonid + '_released');
        });
    }
};

let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks});
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

function draw2(imgData) {
    "use strict";
    var canvas = document.getElementById("canvas");
    var ctx = canvas.getContext("2d");
    var uInt8Array = new Uint8Array(imgData);
    var i = uInt8Array.length;
    var binaryString = [i];
    while (i--) {
        binaryString[i] = String.fromCharCode(uInt8Array[i]);
    }
    var data = binaryString.join('');

    var base64 = window.btoa(data);
    var img = new Image();
    img.src = "data:image/jpeg;base64," + base64;
    img.onload = function () {
        canvas.width = img.naturalWidth;
        canvas.height = img.naturalHeight;
        ctx.drawImage(img, 0,0, canvas.width, canvas.height);
    };
    img.onerror = function (stuff) {
        console.log("Img Onerror:", stuff);
    };

}

window.addEventListener("phx:js-frame", ({detail}) => {
    draw2(detail.frameData);
});

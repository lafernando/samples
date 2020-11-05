var ws = new WebSocket("ws://localhost:8080/ws/subscribe");
ws.onmessage = function(frame) {console.log(frame.data)};

import ballerina/http;

@http:WebSocketServiceConfig {
    path: "/basic/ws",
    subProtocols: ["xml", "json"],
    idleTimeoutInSeconds: 120
}
service locationServiceWS on new http:Listener(8084) {

    // This `resource` is triggered when a new text frame is received from a client.
    resource function onText(http:WebSocketCaller caller, string text, boolean finalFrame) returns @tainted error? {
        http:Client locSvc = new("http://localhost:8080");
        if text == "location" {
            var resp = check locSvc->get("/mylocation");
            json payload = check resp.getJsonPayload();
            _ = check caller->pushText("Location: " + <@untainted> payload.toJsonString());
        } else {
            _ = check caller->pushText("Unknown command: " + <@untainted> text);
        }
    }

}

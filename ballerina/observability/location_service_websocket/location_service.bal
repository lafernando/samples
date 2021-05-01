import ballerina/http;
import ballerina/websocket;
import ballerinax/prometheus as _;
import ballerinax/jaeger as _;

@websocket:ServiceConfig {
    subProtocols: ["xml", "json"],
    idleTimeout: 120
}
service /mylocation on new websocket:Listener(8084) {

   resource isolated function get .() returns websocket:Service {
       return new WsService();
   }
   
}

service class WsService {

    *websocket:Service;

    remote function onTextMessage(websocket:Caller caller, string text) returns error? {
        http:Client locSvc = check new("http://localhost:8080");
        if text == "location" {
            var resp = check locSvc->get("/locationService/mylocation");
            json payload = check resp.getJsonPayload();
            var rx = check caller->writeTextMessage("Location: " + <@untainted> payload.toJsonString());
        } else {
            _ = check caller->writeTextMessage("Unknown command: " + <@untainted> text);
        }
    }

}
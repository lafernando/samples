import ballerina/http;

@http:WebSocketServiceConfig {
    path: "/ws/echo"
}
service echo on new http:Listener(8080) {

    resource function onText(http:WebSocketCaller caller, string data) returns error? {
        check caller->pushText("Echo: " + data);
    }

    resource function onBinary(http:WebSocketCaller caller, byte[] data) returns error? {
        check caller->pushBinary(data);
    }

}

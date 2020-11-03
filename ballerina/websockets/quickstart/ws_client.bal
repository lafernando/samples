import ballerina/http;
import ballerina/io;

public function main() returns error? {
    http:WebSocketClient wsclient = new("ws://localhost:8080/ws/echo", config = {callbackService: clientService});
    check wsclient->pushText("Hello!", true);
    check wsclient->close();
}

service clientService = @http:WebSocketServiceConfig {} service {

    resource function onText(http:WebSocketClient conn, string text, boolean fin) {
        io:println(text);
    }

    resource function onError(http:WebSocketClient conn, error err) {
        io:println(err);
    }

};

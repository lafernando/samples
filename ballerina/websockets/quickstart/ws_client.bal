import ballerina/config;
import ballerina/http;
import ballerina/io;

http:WebSocketClientConfiguration wsConf = {
    secureSocket: {
        trustStore: {
            path: config:getAsString("b7a.home") +
                "/bre/security/ballerinaTruststore.p12",
            password: "ballerina"
        }
    },
    callbackService: clientService
};

public function main() returns error? {
    http:WebSocketClient wsClient = new ("wss://localhost:8443/ws/echo", 
                                         config = wsConf);
    check wsClient->pushText("Hello!", true);
    check wsClient->close();
}

service clientService = @http:WebSocketServiceConfig {} service {

    resource function onText(http:WebSocketClient conn, string text, 
                             boolean fin) {
        io:println(text);
    }

};

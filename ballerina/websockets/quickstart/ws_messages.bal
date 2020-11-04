import ballerina/http;
import ballerina/config;

http:ListenerConfiguration httpConf = {
    secureSocket: {
        keyStore: {
            path: config:getAsString("b7a.home") +
                  "/bre/security/ballerinaKeystore.p12",
            password: "ballerina"
        }
    }
};

listener http:Listener listEp = new (8443, config = httpConf);

@http:WebSocketServiceConfig {
    path: "/ws/echo"
}
service echo on listEp {

    resource function onText(http:WebSocketCaller caller, string data) 
                             returns error? {
        check caller->pushText("Echo: " + data);
    }

}

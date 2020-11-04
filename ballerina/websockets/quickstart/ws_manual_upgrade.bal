import ballerina/http;

http:WebSocketCaller[] callers = [];

service subscriber = @http:WebSocketServiceConfig { 
                     path: "/ws/subscribe" } service {

    resource function onOpen(http:WebSocketCaller caller) {
        callers.push(caller);
    }

};

@http:ServiceConfig {
    basePath: "/"
}
service broadcaster on new http:Listener(8080) {

    resource function broadcast(http:Caller caller, http:Request request) 
                                returns @tainted error? {
        foreach var targetCaller in callers {
            check targetCaller->pushText(check request.getTextPayload());
            check caller->ok();
        }
    }

    @http:ResourceConfig {
        webSocketUpgrade: {
            upgradePath: "/ws/subscribe",
            upgradeService: subscriber
        }
    }
    resource function subscribeWSUpgrader(http:Caller caller, 
                                          http:Request request) { }

}

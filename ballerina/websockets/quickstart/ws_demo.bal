import ballerina/http;
import ballerina/file;

http:WebSocketCaller[] callers = [];

@http:WebSocketServiceConfig {
    path: "/ws/subscribe"
}
service broadcaster on new http:Listener(8080) {

    resource function onOpen(http:WebSocketCaller caller) {
        callers.push(caller);
    }

    resource function onText(http:WebSocketCaller caller, string data) returns error? {
        check caller->pushText(string `You said ${data}`);
    }

}

service directoryListener on new file:Listener({path: "/home/laf/demo/"}) {

    resource function onCreate(file:FileEvent event) returns error? {
        string msg = event.name;
        foreach var caller in callers {
            check caller->pushText("New file created: " + msg);            
        }
    }

}
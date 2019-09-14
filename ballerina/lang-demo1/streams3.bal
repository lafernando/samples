import ballerina/http;
import ballerina/io;

type Request record {
    string host;
};

type ThrottleEvent record {
    string host;
    int count;
};

stream<Request> requestStream = new;
stream<ThrottleEvent> throttleStream = new;

function initQueries() returns () {
    throttleStream.subscribe(onThrottleEvent);
    forever {
        from requestStream window timeBatch(10000)
        select requestStream.host, count() as count
            group by requestStream.host
            having count > 6
        => (ThrottleEvent[] es) {
            foreach var e in es {
                throttleStream.publish(e);
            }
        }
    }
}

function onThrottleEvent(ThrottleEvent event) {
    io:println("Throttled: ", event);
}

service myservice on new http:Listener(9090) {    
    
    function __init() {
        initQueries();
    }

    resource function request(http:Caller caller, http:Request httpReq) returns error? {
        string host = caller.remoteAddress.host;
        Request req = { host: host };
        requestStream.publish(req);
        check caller->respond("OK");
    }
    
}

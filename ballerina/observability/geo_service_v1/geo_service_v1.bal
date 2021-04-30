import ballerina/http;
import ballerinax/prometheus as _;
import ballerinax/jaeger as _;

type Entry record {|
    float lat;
    float long;
    string src = "UNKNOWN";
    string address;
    string ref?;
|};

map<Entry> entries = {};

service /geoService on new http:Listener(8081) {

    resource function get lookup/[float lat]/[float long](http:Caller caller) returns string|error? {
        json coords = {lat,long};
        Entry? entry = entries[coords.toJsonString()];
        if entry is Entry {
            return entry.address;
        } else {
            http:Response resp = new;
            resp.statusCode = 404;
            check caller->respond(resp);
        }
    }

    resource function post store(http:Caller caller, @http:Payload Entry entry) returns error? {
        json coords = {lat: entry.lat, long: entry.long};
        entries[coords.toJsonString()] = entry;
        http:Response resp = new;
        check caller->respond(resp);
    }

}

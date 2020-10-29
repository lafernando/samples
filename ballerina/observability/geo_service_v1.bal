import ballerina/http;

type Entry record {|
    float lat;
    float long;
    string src = "UNKNOWN";
    string address;
    string ref?;
|};

map<Entry> entries = {};

@http:ServiceConfig {
    basePath: "/"
}
service geoService on new http:Listener(8081) {

    @http:ResourceConfig {
        path:"/lookup/{lat}/{long}",
        methods: ["GET"]
    }
    resource function lookup(http:Caller caller, http:Request request, float lat, float long) returns error? {
        json coords = {lat,long};
        Entry? entry = entries[coords.toJsonString()];
        if entry is Entry {
            check caller->ok(entry.address);
        } else {
            check caller->notFound();
        }
    }

    @http:ResourceConfig {
        path:"/store",
        methods: ["POST"],
        body: "entry"
    }
    resource function store(http:Caller caller, http:Request request, Entry entry) returns error? {
        json coords = {lat: entry.lat, long: entry.long};
        entries[coords.toJsonString()] = <@untainted> entry;
        check caller->ok();
    }

}

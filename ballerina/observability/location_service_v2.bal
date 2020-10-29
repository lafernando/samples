import ballerina/http;
import ballerina/system;
import ballerina/io;

@http:ServiceConfig {
    basePath: "/"
}
service locationService on new http:Listener(8080) {

    // https://developers.google.com/maps/documentation/geolocation/overview
    // https://developers.google.com/maps/documentation/geocoding/overview
    resource function mylocation(http:Caller caller, http:Request request) returns @tainted error? {
        http:Client glClient = new("https://www.googleapis.com");
        http:Client gcClient = new("https://maps.googleapis.com");
        string apiKey = system:getEnv("GC_KEY");
        json payload = { considerIp: true };
        var resp = check glClient->post(string `/geolocation/v1/geolocate?key=${apiKey}`, payload);
        json jr = <@untainted> check resp.getJsonPayload();
        float lat = <float> jr.location.lat;
        float long = <float> jr.location.lng;
        string? address = <@untainted> check lookupLocal(lat, long);
        if address == () {
            resp = check gcClient->get(<@untainted> string `/maps/api/geocode/json?latlng=${lat},${long}&key=${apiKey}`);
            json locationInfo = <@untainted> check resp.getJsonPayload();
            json[] addrs = from var item in <json[]> check locationInfo.results 
                           where item.geometry.location_type == "GEOMETRIC_CENTER"
                           select check item.formatted_address;
            address = <string> addrs[0];
            if address is string {
                check storeLocal(lat, long, "GoogleGeoCode", address);
            }
        }
        check caller->respond(<@untainted> {location: {lat, long}, address});
    }

}

function lookupLocal(float lat, float long) returns @tainted string|error? {
    http:Client localSvcClient = new("http://localhost:8081");
    var resp = check localSvcClient->get(string `/lookup/${lat}/${long}`);
    if resp.statusCode == 404 {
        io:println(string `Local lookup miss: ${lat},${long}`);
        return ();
    } else {
        io:println(string `Local lookup hit: ${lat},${long}`);
        return check resp.getTextPayload();
    }
}

function storeLocal(float lat, float long, string src, string address) returns @tainted error? {
    http:Client localSvcClient = new("http://localhost:8081");
    json payload = {lat, long, src, address, ref: system:uuid()};
    var x = check localSvcClient->post("/store", payload);
    io:println(string `Local lookup store: ${lat},${long}`);
}
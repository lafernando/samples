import ballerina/os;
import ballerina/http;

service /locationService on new http:Listener(8080) {

    // https://developers.google.com/maps/documentation/geolocation/overview
    // https://developers.google.com/maps/documentation/geocoding/overview
    resource function get mylocation() returns json|error? {
        http:Client glClient = check new("https://www.googleapis.com");
        http:Client gcClient = check new("https://maps.googleapis.com");
        string apiKey = os:getEnv("GC_KEY");
        json payload = { considerIp: true };
        var resp = check glClient->post(string `/geolocation/v1/geolocate?key=${apiKey}`, payload);
        json jr = <@untainted> check resp.getJsonPayload();
        float lat = <float> check jr.location.lat;
        float long = <float> check jr.location.lng;
        resp = check gcClient->get(<@untainted> string `/maps/api/geocode/json?latlng=${lat},${long}&key=${apiKey}`);
        json locationInfo = <@untainted> check resp.getJsonPayload();
        json[] addrs = from var item in <json[]> check locationInfo.results 
                       where check item.geometry.location_type == "GEOMETRIC_CENTER"
                       select check item.formatted_address;
        string address = <string> addrs[0];
        return {location: {lat, long}, address};
    }

}

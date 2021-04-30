import ballerina/http;
import ballerinax/mysql;
import ballerinax/prometheus as _;
import ballerinax/jaeger as _;

type Entry record {|
    float lat;
    float long;
    string src = "UNKNOWN";
    string address;
    string ref?;
|};

mysql:Client dbClient = check new(database = "GEO_DB", user = "root", password = "root");

type Address record {string address;};

service /geoService on new http:Listener(8081) {

    resource function get lookup/[float lat]/[float long](http:Caller caller) returns string|error? {
        stream<record{}, error> rs = dbClient->query(`SELECT address FROM GEO_ENTRY WHERE lat = ${lat} AND lng = ${long}`, Address);
        record {|record {} value;|}? rec = check rs.next();
        check rs.close();
        if !(rec is ()) { 
            return (<Address> rec["value"]).address;
        } else {
            http:Response resp = new;
            resp.statusCode = 404;
            check caller->respond(resp);
        }
    }

    resource function post store(http:Caller caller, @http:Payload Entry entry) returns error? {
        _ = check dbClient->execute(`INSERT INTO GEO_ENTRY (lat, lng, src, address, ref) VALUES (
                                    ${entry.lat},${entry.long},${entry.src},${entry.address},${entry?.ref.toString()})`);
        http:Response resp = new;
        check caller->respond(resp);
    }

}
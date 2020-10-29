import ballerina/http;
import ballerinax/java.jdbc;

type Entry record {|
    float lat;
    float long;
    string src = "UNKNOWN";
    string address;
    string ref?;
|};

jdbc:Client dbClient = new ({
    url: "jdbc:mysql://localhost:3306/GEO_DB?serverTimezone=UTC",
    username: "root",
    password: "root"
});

@http:ServiceConfig {
    basePath: "/"
}
service geoService on new http:Listener(8081) {

    @http:ResourceConfig {
        path:"/lookup/{lat}/{long}",
        methods: ["GET"]
    }
    resource function lookup(http:Caller caller, http:Request request, float lat, float long) returns @tainted error? {
            var rs = check dbClient->select("SELECT address FROM GEO_ENTRY WHERE lat = ? AND lng = ?", 
                                             record {string address;}, lat, long);
            if rs.hasNext() {
                check caller->ok(<@untainted> <string> rs.getNext()["address"]);
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
        _ = check dbClient->update("INSERT INTO GEO_ENTRY (lat, lng, src, address, ref) VALUES (?,?,?,?,?)", 
                                    entry.lat, entry.long, entry.src, entry.address, entry?.ref.toString());
        check caller->ok();
    }

}
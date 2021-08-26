import ballerina/http;
import ballerina/io;
import ballerina/runtime;
import laf/commons as x;

http:Client adminClient = new("http://localhost:8085/Admin");

public function main(int interval, int count) returns @tainted error? {
    foreach var i in 1...count {
        check doSession(<@untainted> i % 2 + 1, i % 10 == 0, i % 30 == 0);
        runtime:sleep(interval);
    }
}

public function doSession(int accountId, boolean doError1, boolean doError2) returns @tainted error? {
    http:Response resp = check adminClient->get("/invsearch/mango");
    json rsx = check resp.getJsonPayload();
    json[] entries = <json[]> rsx;
    int id1 = <int> entries[0].id;
    resp = check adminClient->get("/invsearch/water");
    rsx = check resp.getJsonPayload();
    entries = <json[]> rsx;
    int id2 = <int> entries[0].id;
    x:Item item1 = { invId: id1, quantity: 5 };
    x:Item item2 = { invId: id2, quantity: 10 };
    _ = check adminClient->post("/cartitems/" + accountId.toString(), <@untainted> check json.constructFrom(item1));
    _ = check adminClient->post("/cartitems/" + accountId.toString(), <@untainted> check json.constructFrom(item2));
    if doError1 {
        // try to add the same item again
        _ = check adminClient->post("/cartitems/" + accountId.toString(), <@untainted> check json.constructFrom(item2));
    }
    resp = check adminClient->get("/checkout/" + accountId.toString());
    if doError2 {
        // try to checkout an empty cart
        resp = check adminClient->get("/checkout/" + accountId.toString());
    }
    io:println(resp.getTextPayload());
}
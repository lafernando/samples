import ballerina/http;
import ballerina/lang.runtime;
import ballerina/observe;
import ballerinax/choreo as _;

public type Item record {
    int invId;
    int quantity;
};

http:Client adminClient = check new("http://localhost:8085/Admin");

public function main(decimal interval, int count) returns error? {
    foreach var i in 1...count {
        check doSession(i % 2 + 1, i % 10 == 0, i % 30 == 0);
        runtime:sleep(interval / 1000.0);
    }
}

@observe:Observable
public function doSession(int accountId, boolean doError1, boolean doError2) returns error? {
    http:Response resp = check adminClient->get("/invsearch/mango");
    json rsx = check resp.getJsonPayload();
    json[] entries = <json[]> rsx;
    int id1 = <int> check entries[0].id;
    resp = check adminClient->get("/invsearch/water");
    rsx = check resp.getJsonPayload();
    entries = <json[]> rsx;
    int id2 = <int> check entries[0].id;
    Item item1 = { invId: id1, quantity: 5 };
    Item item2 = { invId: id2, quantity: 10 };
    _ = check adminClient->post("/cartitems/" + accountId.toString(), check item1.cloneWithType(json), targetType = http:Response);
    _ = check adminClient->post("/cartitems/" + accountId.toString(), check item2.cloneWithType(json), targetType = http:Response);
    if doError1 {
        // try to add the same item again
        _ = check adminClient->post("/cartitems/" + accountId.toString(), check item2.cloneWithType(json), targetType = http:Response);
    }
    resp = check adminClient->get("/checkout/" + accountId.toString());
    if doError2 {
        // try to checkout an empty cart
        resp = check adminClient->get("/checkout/" + accountId.toString());
    }
}
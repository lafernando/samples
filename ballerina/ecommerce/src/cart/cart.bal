import ballerina/http;
import laf/commons as x;

map<x:Item[]> itemMap = {};

service ShoppingCart on new http:Listener(8080) {

    @http:ResourceConfig {
        path: "/items/{accountId}",
        body: "item",
        methods: ["POST"]
    }
    resource function addItem(http:Caller caller, http:Request request, 
                              string accountId, x:Item item) returns error? {
        x:Item[]? items = itemMap[accountId];
        if items is () {
            x:Item[] newitems = [];
            items = newitems;
            itemMap[accountId] = newitems;
        }
        if items is x:Item[] {
            items.push(item);
        }
        check caller->ok();
    }

    @http:ResourceConfig {
        path: "/items/{accountId}",
        methods: ["GET"]
    }
    resource function getItems(http:Caller caller, http:Request request, 
                               string accountId) returns error? {
        x:Item[]? items = itemMap[accountId];
        if items is () {
            http:Response resp = new;
            resp.statusCode = 404;
            check caller->respond(resp);
        } else {
            check caller->ok(check json.constructFrom(items));
        }

    }

    @http:ResourceConfig {
        path: "/items/{accountId}",
        methods: ["DELETE"]
    }
    resource function clearItems(http:Caller caller, http:Request request, 
                                 string accountId) returns error? {
        itemMap[accountId] = [];
        check caller->ok();
    }

}
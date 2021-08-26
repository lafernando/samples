import ballerina/http;
import ballerina/url;
import ecommerce.commons as x;

http:Client cartClient = check new("http://localhost:8080/ShoppingCart");
http:Client orderMgtClient = check new("http://localhost:8081/OrderMgt");
http:Client billingClient = check new("http://localhost:8082/Billing");
http:Client shippingClient = check new("http://localhost:8083/Shipping");
http:Client invClient = check new("http://localhost:8084/Inventory");

type ItemArray x:Item[];

service /admin on new http:Listener(8085) {

    resource function get invsearch/[string query](http:Caller caller, http:Request request) returns error? {
        http:Response resp = check invClient->get("/search/" + check url:encode(query, "UTF-8"));
        check caller->respond(resp);
    }

    resource function post cartitems/[int accountId](http:Caller caller, http:Request request, 
                                      @http:Payload x:Item item) returns error? {
        http:Response resp = check cartClient->post("/items/" + accountId.toString(), check item.cloneWithType(json));
        check caller->respond(resp);
    }

    resource function get checkout/[int accountId](http:Caller caller, http:Request request) returns error? {
        http:Response resp = check cartClient->get("/items/" + accountId.toString());
        json payload = check resp.getJsonPayload();
        x:Item[] items = check payload.cloneWithType(ItemArray);
        if items.length() == 0 {
            http:Response respx = new;
            respx.statusCode = 400;
            respx.setTextPayload("Empty cart");
            check caller->respond(respx);
            return;
        }
        x:Order orderx = { accountId, items };
        resp = check orderMgtClient->post("/order", check orderx.cloneWithType(json));
        string orderId = check resp.getTextPayload();
        x:Payment payment = { orderId };
        resp = check billingClient->post("/payment", check payment.cloneWithType(json));
        string receiptNumber = check resp.getTextPayload();
        x:Delivery delivery = { orderId };
        resp = check shippingClient->post("/delivery", check delivery.cloneWithType(json));
        string trackingNumber = check resp.getTextPayload();
        () x = check cartClient->delete("/items/" + accountId.toString());
        check caller->respond({ accountId: accountId, orderId: orderId, receiptNumber: receiptNumber, 
                                trackingNumber: trackingNumber });
    }

}
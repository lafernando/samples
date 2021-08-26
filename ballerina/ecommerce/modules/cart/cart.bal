import ballerina/http;
import ballerinax/mysql;
import ecommerce.commons as x;

mysql:Client dbClient = check new(database = "ECOM_DB?serverTimezone=UTC", user = "root", password = "root");

service /ShoppingCart on new http:Listener(8080) {

    resource function post items/[int accountId](@http:Payload x:Item item) returns error? {
        _ = check dbClient->execute(`INSERT INTO ECOM_ITEM (inventory_id, account_id, quantity) VALUES (
                                     ${item.invId},${accountId},${item.quantity})`);
    }

    resource function get items/[int accountId]() returns json|error? {
        stream<x:Item, error> rs = dbClient->query(`SELECT inventory_id as invId, quantity FROM ECOM_ITEM WHERE account_id = ${accountId}`, x:Item);
        record {|record {} value;|}? rec = check rs.next();
        json[] result = [];
        error e = rs.forEach(function(x:Item item) {
            result.push(checkpanic item.cloneWithType(json));
        });
        check rs.close();
        return result;
    }

    resource function delete items/[int accountId]() returns error? {
        _ = check dbClient->execute(`DELETE FROM ECOM_ITEM WHERE account_id = ${accountId}`);
    }

}

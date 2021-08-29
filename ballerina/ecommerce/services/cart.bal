import ballerina/http;
import ballerinax/choreo as _;

service /ShoppingCart on new http:Listener(8080) {

    resource function post items/[int accountId](@http:Payload Item item) returns error? {
        _ = check dbClient->execute(`INSERT INTO ECOM_ITEM (inventory_id, account_id, quantity) VALUES (
                                     ${item.invId},${accountId},${item.quantity})`);
    }

    resource function get items/[int accountId]() returns json|error? {
        stream<Item, error> rs = dbClient->query(`SELECT inventory_id as invId, quantity FROM ECOM_ITEM WHERE account_id = ${accountId}`, Item);
        json[] result = [];
        error e = rs.forEach(function(Item item) {
            result.push(checkpanic item.cloneWithType(json));
        });
        check rs.close();
        return result;
    }

    resource function delete items/[int accountId]() returns error? {
        _ = check dbClient->execute(`DELETE FROM ECOM_ITEM WHERE account_id = ${accountId}`);
    }

}

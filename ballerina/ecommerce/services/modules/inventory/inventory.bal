import ballerina/http;
import ballerinax/mysql;
import ecommerce.commons as x;

mysql:Client dbClient = check new(database = "ECOM_DB?serverTimezone=UTC", user = "root", password = "root");

service /Inventory on new http:Listener(8084) {

    resource function get search/[string query]() returns json|error? {
        stream<x:Inventory, error> rs = dbClient->query("SELECT id, description FROM ECOM_INVENTORY WHERE description LIKE '%" + query + "%'", x:Inventory);
        json[] result = [];
        error e = rs.forEach(function(x:Inventory item) {
            result.push(checkpanic item.cloneWithType(json));
        });
        check rs.close();
        return result;
    }

}

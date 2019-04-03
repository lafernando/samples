import ballerina/mysql;
import ballerina/system;

mysql:Client dbclient = new({
    host: "localhost",
    name: "ordermgt",
    username: "root",
    password: "root",
    dbOptions: { useSSL: false }
});

public function createOrder(json orderInfo) returns string {
    string id = system:uuid();
    _ = dbclient->update("INSERT INTO orders (id,info,state) VALUES (?,?, 'CREATED')", 
                         id, orderInfo.toString());
    return id;
}

public function getOrder(string id) returns json?|error {
    table<record{}> result = check dbclient->select("SELECT * FROM orders WHERE id = ?", (), id);
    json jr = check json.convert(result);
    if (jr.length() == 0) {
        return ();
    } else {
        return jr[0];
    }
}

public function updateOrderInfo(string id, json orderInfo) returns error|boolean {
    var result = dbclient->update("UPDATE orders SET info = ? WHERE id = ?", 
                                  orderInfo.toString(), id);
    if (result is error) {
        return result;
    } else {
        return result > 0;
    }
}

public function updateOrderState(string id, string orderState) returns error|boolean {
    var result = dbclient->update("UPDATE orders SET state = ? WHERE id = ?", orderState, id);
    if (result is error) {
        return result;
    } else {
        return result > 0;
    }
}
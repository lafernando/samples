import ballerina/graphql;
import ballerinax/mysql;

mysql:Client dbClient = check new(database = "ORDER_DB", user = "root", password = "root");

type OrderData record {
    int id;
    int customerId;
    int shipperId;
    string date;
    string notes;
};

type CustomerData record {
    int id;
    string name;
    string address;
};

type ShipperData record {
    int id;
    string name;
    string phone;
};

service class Customer {

    private CustomerData data;

    function init(CustomerData data) {
        self.data = data;
    }

    resource function get name() returns string {
        return self.data.name;
    }

    resource function get address() returns string {
        return self.data.address;
    }
}

service class Shipper {

    private ShipperData data;

    function init(ShipperData data) {
        self.data = data;
    }

    resource function get name() returns string {
        return self.data.name;
    }

    resource function get phone() returns string {
        return self.data.phone;
    }
}

service class Order {

    private OrderData data;

    function init(OrderData data) {
        self.data = data;
    }

    resource function get notes() returns string {
        return self.data.notes;
    }

    resource function get date() returns string {
        return self.data.date;
    }

    resource function get customer() returns Customer|error {
        return check loadCustomer(self.data.customerId);
    }

    resource function get shipper() returns Shipper|error {
        return check loadShipper(self.data.shipperId);
    }
}

service graphql:Service /query on new graphql:Listener(8080) {

    resource function get 'order(int id) returns Order|error => loadOrder(id);

}

function loadOrder(int id) returns Order|error {
    stream<record{}, error> rs = dbClient->query(`SELECT id, customerId, shipperId, date, notes 
                                                  FROM ORDERS WHERE id = ${id}`, OrderData);
    var rec = check rs.next();
    check rs.close();
    if !(rec is ()) { 
        return new Order(<OrderData> rec["value"]);
    } else {
        return error(string `Invalid order: ${id}`);
    }
}

function loadCustomer(int id) returns Customer|error {
    stream<record{}, error> rs = dbClient->query(`SELECT id, name, address
                                                  FROM CUSTOMER WHERE id = ${id}`, CustomerData);
    var rec = check rs.next();
    check rs.close();
    if !(rec is ()) { 
        return new Customer(<CustomerData> rec["value"]);
    } else {
        return error(string `Invalid customer: ${id}`);
    }
}

function loadShipper(int id) returns Shipper|error {
    stream<record{}, error> rs = dbClient->query(`SELECT id, name, phone
                                                  FROM SHIPPER WHERE id = ${id}`, ShipperData);
    var rec = check rs.next();
    check rs.close();
    if !(rec is ()) { 
        return new Shipper(<ShipperData> rec["value"]);
    } else {
        return error(string `Invalid shipper: ${id}`);
    }
}

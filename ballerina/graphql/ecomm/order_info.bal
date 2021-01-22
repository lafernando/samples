import ballerina/graphql;

type OrderData record {|
    int id;
    int customerId;
    int shipperId;
    string date;
    string notes;
|};

type CustomerData record {|
    int id;
    string name;
    string address;
|};

type ShipperData record {|
    int id;
    string name;
    string phone;
|};

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

    resource function get shipper() returns Customer|error {
        return check loadCustomer(self.data.customerId);
    }
}

service graphql:Service /graphql on new graphql:Listener(8080) {

    resource function get orders(int id) returns Order|error => loadOrder(id);

}

function loadOrder(int id) returns Order|error {
    //stream<OrderData, *> stm = dbc->query(`SELECT * FROM Order WHERE id = ${id}`);
    OrderData data = {
        id: 1001,
        customerId: 2115,
        shipperId: 2411,
        date: "2020/01/01",
        notes: "Urgent"
    };
    return new Order(data);
}

function loadCustomer(int id) returns Customer|error {
    CustomerData data = {id: 3001, name: "Jack", address: "No 10, Main Street"};
    return new Customer(data);
}

import ballerinax/java.jdbc;
import ballerina/sql;

public type Customer record {
    int customer_id;
    string first_name;
    string middle_name;
    string last_name;
    string suffix;
    string email;
    string phone;
};

configurable string DB_URL = ?;
configurable string DB_USER = ?;
configurable string DB_PASSWORD = ?;

jdbc:Client dbClient = check new (DB_URL, DB_USER, DB_PASSWORD);
public function findAllCustomers() returns Customer[]|error {
    Customer[] customers = [];
    stream<Customer, sql:Error> rs = <stream<Customer, sql:Error>> dbClient->query(`SELECT * from customer`, Customer);
    error e = rs.forEach(function (Customer customer) {
        customers.push(customer);
    });
    return customers;
}

public function findCustomerById(int customerId) returns Customer?|error {
    stream<Customer, sql:Error> rs = <stream<Customer, sql:Error>> dbClient->query(
                                     `SELECT * from customer where customer_id = ${customerId}`, Customer);
    record {|record {} value;|}? result = check rs.next();
    if result is record {|record {} value;|} {
        return <Customer> result.value;
    } else {
        return ();
    }
}

public function saveCustomer(Customer customer) returns error? {
    var result = check dbClient->execute(`INSERT INTO customer (first_name, middle_name, last_name, suffix, email, 
        phone) VALUES (${customer.first_name}, ${customer.middle_name}, ${customer.last_name}, 
        ${customer.suffix}, ${customer.email}, ${customer.phone})`);
    customer.customer_id = <int> result.lastInsertId;
}

public function update(Customer customer) returns error? {

}

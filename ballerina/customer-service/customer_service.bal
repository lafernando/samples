import ballerina/http;

configurable int SERVICE_PORT = ?;

service /api/customers on new http:Listener(SERVICE_PORT) {

    resource function get . () returns Customer[]|error {
        return findAllCustomers();
    }

    resource function get [int customerId]() returns Customer?|error {
        return findCustomerById(customerId);
    }

    resource function post . (@http:Payload Customer customer) returns Customer|error? {
        check saveCustomer(customer);
        return customer;
    }

    resource function put . (@http:Payload Customer customer) returns error? {

    }

}

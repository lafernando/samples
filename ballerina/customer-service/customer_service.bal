import ballerina/http;
service /api/customers on new http:Listener(8080) {

    resource function get . () returns Customer[]|error {
        Customer[] customers = [];
        return customers;
    }

    resource function get [int customerId]() returns Customer?|error {
        return ();
    }

    resource function post . (@http:Payload Customer customer) returns error? {

    }

    resource function put . (@http:Payload Customer customer) returns error? {

    }

}

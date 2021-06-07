import ballerina/http;

configurable int SERVICE_PORT = ?;

# Customer API.
service /api/customers on new http:Listener(SERVICE_PORT) {

    # Find all customers.
    # + return - List of customers
    resource function get . () returns Customer[]|error {
        return findAllCustomers();
    }

    # Find customer by customerId.
    # + return - Customer
    resource function get [int customerId]() returns Customer?|error {
        return findCustomerById(customerId);
    }

    # Add customer.
    # + return - Added customer (with the populated customerId)
    resource function post . (@http:Payload Customer customer) returns Customer|error? {
        check saveCustomer(customer);
        return customer;
    }

    # Update customer.
    # + return - Updated customer
    resource function put . (@http:Payload Customer customer) returns Customer|error? {
        transaction {
            if (check findCustomerById(customer.customer_id) is ()) {
                rollback;
                return error(string `No Customer found for customerId[${customer.customer_id}]`);
            } else {
                check updateCustomer(customer);
                check commit;
            }
        }
        return customer;
    }

}


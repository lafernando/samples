import ballerina/test;
import ballerina/http;
import ballerina/uuid;
import laf/testcontainers as tc;

http:Client customerSvc = check new("http://localhost:8080/api/customers");

@test:BeforeSuite
public function setup() {
    _ = tc:newPostgreSQLContainer3("postgres:9.6.12");
}

@test:Config 
public function findAllCustomersTest() returns error? {
    Customer[] customers = check customerSvc->get("/");
    test:assertTrue(customers.length() > 1);
}

@test:Config 
public function findCustomerByIdTest() returns error? {
    Customer customer = check customerSvc->get("/1");
    test:assertEquals(customer.first_name, "John");
    customer = check customerSvc->get("/2");
    test:assertEquals(customer.first_name, "Jane");
}

@test:Config 
public function saveCustomerTest() returns error? {
    Customer customer = check createCustomer();
    customer = check customerSvc->post("/", check customer.cloneWithType(json));
    test:assertTrue(customer.customer_id > 0);
}

@test:Config 
public function updateCustomerTest() returns error? {
    Customer customer = check createCustomer();
    customer = check customerSvc->post("/", check customer.cloneWithType(json));
    customer.first_name = "Updated";
    customer = check customerSvc->put("/", check customer.cloneWithType(json));
    test:assertEquals(customer.first_name, "Updated");
}

function customerEquals(Customer lhs, Customer rhs) returns boolean {
    return lhs.customer_id == rhs.customer_id &&
           lhs?.email == rhs?.email &&
           lhs.first_name == rhs.first_name &&
           lhs.last_name == rhs.last_name &&
           lhs?.middle_name == rhs?.middle_name &&
           lhs?.phone == rhs?.phone &&
           lhs?.suffix == rhs?.suffix;
}

function createCustomer() returns Customer|error {
    Customer customer = {
        customer_id: 0,
        first_name: uuid:createType4AsString().toString(),
        middle_name: uuid:createType4AsString().toString(),
        last_name: uuid:createType4AsString().toString(),
        suffix: uuid:createType4AsString().toString(),
        email: uuid:createType4AsString().toString() + "@foo.com"
    };
    return customer;
}
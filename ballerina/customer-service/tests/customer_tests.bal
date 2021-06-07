import ballerina/test;
import ballerina/http;
import laf/testcontainers as tc;

http:Client customerSvc = check new("http://localhost:8080/api/customers");

@test:BeforeSuite
public function setup() {
    _ = tc:newPostgreSQLContainer3("postgres:9.6.12");
}

type Customers Customer[];

@test:Config 
public function findAllCustomersTest() returns error? {
    Customer[] customers = check customerSvc->get("/", (), Customers);
    test:assertEquals(customers.length(), 2);
}

@test:Config 
public function findCustomerByIdTest() returns error? {
    Customer entry = check customerSvc->get("/1/", (), Customer);
    test:assertEquals(entry.first_name, "John");
    entry = check customerSvc->get("/2/", (), Customer);
    test:assertEquals(entry.first_name, "Jane");
}

import ballerina/test;
import laf/testcontainers as tc;

@test:BeforeSuite
public function setup() {
    _ = tc:newPostgreSQLContainer3("postgres:9.6.12");
}

@test:Config 
public function findAllCustomersTest() returns error? {
    Customer[] customers = check findAllCustomers();
    test:assertEquals(customers.length(), 2);
}

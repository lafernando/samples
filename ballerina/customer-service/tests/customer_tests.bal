import ballerina/test;
import ballerina/io;
import ballerinax/java.jdbc;
import laf/testcontainers as tc;

@test:BeforeSuite
public function setup() {
    _ = tc:newPostgreSQLContainer3("postgres:9.6.12");
}

@test:Config 
public function test1() returns error? {
    io:println("Test1");
    jdbc:Client dbClient = check new ("jdbc:tc:postgresql:9.6.8:///DB1?TC_INITSCRIPT=file:resources/init_db.sql");
    var rs = dbClient->query(`SELECT * from customer`);
    io:println("Result: ", rs.next());
    io:println("Done.");
}
import ballerina/io;
import ballerinax/java.jdbc;

public function main() returns error? {
    jdbc:Client dbClient = check new ("jdbc:tc:postgresql:9.6.8:///DB1");
    var rs = dbClient->query(`SELECT 1`);
    io:println("Result: ", rs);
}

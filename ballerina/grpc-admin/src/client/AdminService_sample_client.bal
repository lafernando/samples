import ballerina/io;
import ballerina/grpc;

public function main (string... args) returns error? {
    AdminServiceBlockingClient blockingEp = new("http://localhost:9090");
    [AddResponse, grpc:Headers] addResult = check blockingEp->add({ numbers: [1, 2, 3, 4] });
    io:println("Add Result: ", addResult[0].result);
    [MultiplyResponse, grpc:Headers] mulResult = check blockingEp->multiply({ v1: 5, v2: 7 });
    io:println("Multiply Result: ", mulResult[0].result);
    Person person = { name: "Jack Dawson", birthYear: 1990 };
    [AddPersonResponse, grpc:Headers] addPersonResult = check blockingEp->addPerson(person);
    io:println("Add Person Result: ", addPersonResult[0].id);
    [Person, grpc:Headers] getPersonResult = check blockingEp->getPerson({ id: addPersonResult[0].id });
    io:println("Get Person Result: ", getPersonResult[0]);
}


import ballerina/http;
import ballerina/io;

http:Client webep = new("http://example.com");

public function main() returns error? {
    int x = 10;
    io:println(x * 2);
    var result = webep->get("/foo");
    if (result is http:Response) {
        io:println(check result.getJsonPayload());
    } else {
        io:println("Error: ", result);
    }
}



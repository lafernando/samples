import ballerina/http;
import ballerina/io;

http:Client webep = new("http://example.com");

public function main() {
    future<int> f10 = start fib(10);
    var result = webep->get("/");
    int x = wait f10;
    if (result is http:Response) {
        io:println(result.getTextPayload());
        io:println(x);
    }
}

function fib(int n) returns int {
    if (n <= 2) {
        return 1;
    } else {
        return fib(n - 1) + fib(n - 2);
    }
}
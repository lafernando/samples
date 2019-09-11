# Ballerina Socket Sample Connector

This is a sample Ballerina connector which demonstrates TCP socket communication features.

## Compatibility
| Ballerina Language Version 
| -------------------------- 
| 1.0.0                     

##### Sample

```ballerina
import ballerina/io;
import ballerina/config;
import lafernando/socketsample;

socketsample:Configuration config = {
    username: config:getAsString("username"),
    password: config:getAsString("password")
};

public function main() returns error? {
    // listen to the socket using `nc -l -p 65000`
    // wait for data
    // enter a 4 character value
    // wait for data
    // enter a 4 character value
    socketsample:Client sclient = check new(config);
    var result = sclient->doAction("HELLO:");
    io:println("Result: ", result);
}
```

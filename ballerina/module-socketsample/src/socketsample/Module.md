Sample Ballerina TCP socket based connector.

# Module Overview

## Compatibility
| Ballerina Language Version 
| -------------------------- 
| 1.0.0

## Sample

```ballerina
import ballerina/io;
import ballerina/config;
import lafernando/socketsample;

socketsample:Configuration config = {
    username: config:getAsString("username"),
    password: config:getAsString("password")
};

public function main() returns error? {
    socketsample:Client sclient = check new(config);
    var result = sclient->doAction("HELLO:");
    io:println("Result: ", result);
}
```

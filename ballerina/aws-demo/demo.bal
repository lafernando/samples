import ballerina/http;
import wso2/amazonrekn;
import ballerina/config;
import ballerina/io;

amazonrekn:Configuration conf = {
    // AK and SK can be given as envionment variables
    // or else can be passed in from a configuration file
    accessKey: config:getAsString("AK"),
    secretKey: config:getAsString("SK")
};

amazonrekn:Client amzonrekn = new(conf);

@http:ServiceConfig {
    basePath: "/"
}
service myservice on new http:Listener(8080) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "process"
    }
    resource function myprocess(http:Caller caller, http:Request request) returns error? {
        byte[] payload = check request.getBinaryPayload();
        string result = check amzonrekn->detectText(<@untainted> payload);
        error? err = caller->respond(result);
        if (err is error) {
            io:println("Error: " , err);
        }
    }

}

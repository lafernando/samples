import ballerina/http;
import wso2/amazonrekn;
import ballerina/config;

amazonrekn:Configuration conf = {
    accessKey: config:getAsString("AK"),
    secretKey: config:getAsString("SK")
};

amazonrekn:Client reknClient = new(conf);

@http:ServiceConfig {
    basePath: "/"
}
service myservice on new http:Listener(8080) {

    @http:ResourceConfig {
        path: "/process",
        methods: ["POST"]
    }
    resource function doit(http:Caller caller, http:Request request) returns @tainted error? {
        byte[] payload = check request.getBinaryPayload();
        var result = reknClient->detectText(<@untainted> payload);
        if result is string {
            check caller->respond(result);
        } else {
            check caller->respond("Error: " + result.toString());
        }
    }

}
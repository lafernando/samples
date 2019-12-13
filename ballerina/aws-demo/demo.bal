
import ballerina/http;
import wso2/amazonrekn;
import ballerina/config;

amazonrekn:Configuration conf = {
    secretKey: config:getAsString("SK"),
    accessKey: config:getAsString("AK")
};

amazonrekn:Client reknClient = new(conf);

@http:ServiceConfig {
    basePath: "/"
}
service ocrservice on new http:Listener(8080) {

    @http:ResourceConfig {
        path: "/process",
        methods: ["POST"]
    }
    resource function process(http:Caller caller, http:Request request) returns error? {
        byte[] payload = check request.getBinaryPayload();
        var response = reknClient->detectText(<@untainted> payload);
        if response is string {
            check caller->respond(response);
        } else {
            check caller->respond("Error: " + response.toString());
        }
    }

}
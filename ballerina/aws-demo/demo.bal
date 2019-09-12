import ballerina/http;
import ballerina/config;
import wso2/amazonrekn;

amazonrekn:Configuration config = {
    accessKey: config:getAsString("AK"),
    secretKey: config:getAsString("SK")
};

amazonrekn:Client reknClient = new(config);

@http:ServiceConfig {
    basePath: "/"
}
service myservice on new http:Listener(9090) {

    @http:ResourceConfig {
        path: "process"
    }
    resource function doit(http:Caller caller, http:Request request) returns error? {
        var input = request.getBinaryPayload();
        if (input is byte[]) {
            var result = reknClient->detectText(<@untainted> input);
            if (result is string) {
                check caller->respond(result);
            }
        }
    }

}

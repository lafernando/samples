import ballerina/http;
import wso2/amazonrekn;
import ballerina/config;
import ballerina/kubernetes;

amazonrekn:Configuration conf = {
    accessKey: config:getAsString("AK"),
    secretKey: config:getAsString("SK")
};

amazonrekn:Client reknClient = new(conf);

@kubernetes:ConfigMap {
    conf: "ballerina.conf"
}
@kubernetes:Service {
    serviceType: "LoadBalancer",
    port: 80
}
@kubernetes:Deployment {
    image: "$env{docker_username}/ocrdemo1",
    username: "$env{docker_username}",
    password: "$env{docker_password}",
    push: true
}
@http:ServiceConfig {
    basePath: "/"
}
service myservice on new http:Listener(8080) {

    @http:ResourceConfig {
        path: "/action",
        methods: ["POST"]
    }
    resource function doit(http:Caller caller, http:Request request) returns error? {
        byte[] payload = check request.getBinaryPayload();
        var result = reknClient->detectText(<@untainted> payload);
        if result is string {
            check caller->respond(result);
        } else {
            check caller->respond("Error: " + result.toString());
        }
    }

}
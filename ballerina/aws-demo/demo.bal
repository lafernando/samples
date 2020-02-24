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
    serviceType: "NodePort"
}
@kubernetes:Deployment {
    dockerHost: "tcp://192.168.99.102:2376", 
    dockerCertPath: "/home/laf/.minikube/certs"
}
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
        byte[] x = payload.sort(function (byte a, byte b) returns int { return a - b; });
        var result = reknClient->detectText(<@untainted> payload);
        if result is string {
            check caller->respond(result);
        } else {
            check caller->respond("Error: " + result.toString());
        }
    }

}
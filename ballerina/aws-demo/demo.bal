import ballerina/http;
import wso2/amazonrekn;
import ballerina/config;
import ballerina/io;
import ballerina/kubernetes;

amazonrekn:Configuration conf = {
    // AK and SK can be given as envionment variables
    // or else can be passed in from a configuration file
    accessKey: config:getAsString("AK"),
    secretKey: config:getAsString("SK")
};

amazonrekn:Client ac = new(conf);

@kubernetes:Deployment {
    dockerHost: "tcp://192.168.99.102:2376", 
    dockerCertPath: "/home/laf/.minikube/certs"
}
@kubernetes:Service {
    serviceType: "NodePort"
}
@kubernetes:ConfigMap {
    conf: "ballerina.conf"
}
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
        string result = check ac->detectText(<@untainted> payload);
        error? err = caller->respond(result);
        if (err is error) {
            io:println("Error: " , err);
        }
    }

}
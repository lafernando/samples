import ballerina/http;
import ballerina/config;
import wso2/amazonrekn;
import ballerinax/kubernetes;
import ballerina/io;

amazonrekn:Configuration config = {
    accessKey: config:getAsString("AK"),
    secretKey: config:getAsString("SK")
};

@kubernetes:Service {
    serviceType: "NodePort"
}
listener http:Listener lx = new(8080);

amazonrekn:Client reknClient = new(config);

@kubernetes:Deployment {
    dockerHost:"tcp://192.168.99.100:2376", 
    dockerCertPath:"/home/laf/.minikube/certs"    
}
@kubernetes:ConfigMap {
    ballerinaConf: "ballerina.conf"
}
@http:ServiceConfig {
    basePath: "/"
}
service myservice on lx {

    @http:ResourceConfig {
        path: "process"
    }
    resource function doit(http:Caller caller, http:Request request) returns error? {
        byte[] input = check request.getBinaryPayload();
        var result = reknClient->detectText(input);
        if (result is string) {
            check caller->respond(result);
        } else {
            io:println(result);
        }
    }

}
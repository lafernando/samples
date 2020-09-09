import wso2/amazonrekn;
import ballerina/config;
import ballerina/http;
import ballerina/kubernetes;

amazonrekn:Configuration conf = {
    accessKey: config:getAsString("AK"),
    secretKey: config:getAsString("SK")
};

amazonrekn:Client reknClient = new (conf);

@kubernetes:ConfigMap {
    conf: "ballerina.conf"
}
@kubernetes:Service {
    serviceType: "NodePort"
}
@kubernetes:Deployment { }
@http:ServiceConfig {
    basePath: "/"
}
service ocrservice on new http:Listener(8080) {

    resource function process(http:Caller caller, http:Request request) returns @tainted error? {
        byte[] result = check request.getBinaryPayload();
        string value = check reknClient->detectText(<@untainted> result);
        check caller->respond(<@untainted> value);
    }

}


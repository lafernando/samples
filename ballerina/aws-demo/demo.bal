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
service ocrservice on new http:Listener(8080) {

    resource function process(http:Caller caller, http:Request request) returns error? {
        byte[]|error result = request.getBinaryPayload();
        string value;
        if result is byte[] {
            value = check reknClient->detectText(<@untainted> result);
        } else {
            value = "Error: " + result.toString();
        }
        check caller->respond(<@untainted> value);
    }

}
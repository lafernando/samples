import ballerina/io;
import ballerina/http;
import ballerina/os;

public function main() returns @tainted error? {
    http:ClientConfiguration clientEpConfig = {
        secureSocket: {
            cert: {
                path: os:getEnv("BAL_HOME") +
                    "/bre/security/ballerinaTruststore.p12",
                password: "ballerina"
            },
            key: {
                path: os:getEnv("BAL_HOME") +
                        "/bre/security/ballerinaKeystore.p12",
                password: "ballerina"
            }
        }
    };
    http:Client clientEp = check new ("https://httpbin.org", clientEpConfig);
    http:Response resp = <http:Response> check clientEp->get("/get");
    io:println("Payload: ", resp.getTextPayload());
}

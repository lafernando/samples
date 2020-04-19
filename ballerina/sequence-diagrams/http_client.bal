import ballerina/http;
import ballerina/io;public function main() {
    http:Client clientEP = new ("http://www.mocky.io");
    var resp = clientEP->get("/v2/5ae082123200006b00510c3d/");    
    if (resp is http:Response) {
        var payload = resp.getTextPayload();
        if (payload is string) {
            io:println(payload);
        } else {
            io:println(payload.detail());
        }
    } else {
        io:println(resp.detail());
    }
}

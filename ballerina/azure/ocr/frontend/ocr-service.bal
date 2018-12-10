import ballerina/io;
import ballerina/system;
import ballerina/http;

@http:ServiceConfig {
    basePath:"/"
}
service OCRService on new http:Listener(8080) {

    @http:ResourceConfig {
        path:"/{email}"
    }
    public resource function submitOCRJob(http:Caller caller, http:Request req, string email) {
        var result = req.getBinaryPayload();
        if (result is byte[]) {
            string jobId = system:uuid();
            _ = caller->respond({ job: { id: jobId }});
            io:println("JOB, ID: " + jobId, " DATA LENGTH:", result.length(), " EMAIL: ", email);
        } else {
            _ = caller->respond("Error, Reason: " + untaint result.reason() + 
                                " Detail: " + <string> untaint result.detail()["message"]);
        }
    }

}


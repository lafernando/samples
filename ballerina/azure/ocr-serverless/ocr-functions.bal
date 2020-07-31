import ballerinax/azure.functions as af;
import ballerina/lang.array;
import ballerina/system;
import wso2/azurecv;

@af:Function
function submitJob(af:Context ctx, 
                   @af:HTTPTrigger { authLevel: "anonymous", route: "submit/{email}" } af:HTTPRequest input, 
                   @af:BlobOutput { path: "images/{headers.X-ARR-LOG-ID}" } af:StringOutputBinding blob,
                   @af:QueueOutput { queueName: "requests" } af:StringOutputBinding requestQueue)
                   returns @af:HTTPOutput string {
    map<json> headers = <map<json>> ctx.metadata.Headers;
    string jobId = headers["X-ARR-LOG-ID"].toString();
    string email = <string> ctx.metadata.email.toString().fromJsonString();
    blob.value = input.body;
    json jobInfo = { jobId, email };
    requestQueue.value = jobInfo.toJsonString();
    return jobInfo.toJsonString();
}

@af:Function
function processImage(@af:QueueTrigger { queueName: "requests" } string queueInput,
                      @af:BlobInput { path: "images/{jobId}" } string? encodedData,
                      @af:QueueOutput { queueName: "results" } af:StringOutputBinding resultQueue) 
                      returns @tainted error? {
    json jobInfo = check queueInput.fromJsonString();
    byte[] data = check array:fromBase64(encodedData.toString());
    azurecv:Client cvClient = new({ key: system:getEnv("AZURE_CV_KEY") });
    string result = check cvClient->ocr(data);
    resultQueue.value = <@untainted> result;
}
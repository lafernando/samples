import ballerina/lang.array;
import ballerina/system;
import wso2/azurecv;
import ballerinax/azure.functions as af;
import ballerinax/googleapis.gmail version 0.12.0;

@af:Function
function submitJob(af:Context ctx, 
                   @af:HTTPTrigger { authLevel: "anonymous", route: "submit/{email}" } string input, 
                   @af:BlobOutput { path: "images/{headers.X-ARR-LOG-ID}" } af:StringOutputBinding blob,
                   @af:QueueOutput { queueName: "requests" } af:StringOutputBinding queueOut,
                   @af:BindingName {} string email)
                   returns @af:HTTPOutput json {
    map<json> headers = <map<json>> ctx.metadata.Headers;
    string jobId = headers["X-ARR-LOG-ID"].toString();
    blob.value = input;
    json jobInfo = { jobId, email };
    queueOut.value = jobInfo.toJsonString();
    return jobInfo;
}

@af:Function
function processImage(@af:QueueTrigger { queueName: "requests" } json jobInfo,
                      @af:BlobInput { path: "images/{jobId}" } string? encodedData,
                      @af:QueueOutput { queueName: "results" } af:StringOutputBinding queueOut) 
                      returns @tainted error? {
    byte[] data = check array:fromBase64(encodedData.toString());
    azurecv:Client cvClient = new({ key: system:getEnv("AZURE_CV_KEY") });
    string text = check cvClient->ocr(data);
    json result = { jobInfo, text };
    queueOut.value = <@untainted> result.toJsonString();
}

@af:Function
function publishResults(@af:QueueTrigger { queueName: "results" } json result) returns @tainted error? {
    _ = check sendEmail(result.jobInfo.jobId.toString(), result.jobInfo.email.toString(), result.text.toString());
}

public function sendEmail(string jobId, string email, string text) returns @tainted [string, string]|error? {
    gmail:GmailConfiguration gmailConfig = {
        oauthClientConfig: {
            accessToken: system:getEnv("GAT"),
            refreshConfig: {
                refreshUrl: gmail:REFRESH_URL,
                refreshToken: system:getEnv("GRT"),
                clientId: system:getEnv("GCI"),
                clientSecret: system:getEnv("GCS")
            }
        }
    };
    gmail:Client gmailClient = new (gmailConfig);
    gmail:MessageRequest messageRequest = {};
    messageRequest.recipient = email;
    messageRequest.sender = system:getEnv("EMAIL_SENDER");
    messageRequest.subject = "OCR Result for Job: " + jobId;
    messageRequest.messageBody = text;
    messageRequest.contentType = gmail:TEXT_PLAIN;
    return gmailClient->sendMessage("me", messageRequest);
}
import ballerinax/azure.functions as af;
import ballerina/lang.array;
import ballerina/system;
import wso2/azurecv;
import wso2/gmail;

@af:Function
function submitJob(af:Context ctx, 
                   @af:HTTPTrigger { authLevel: "anonymous", route: "submit/{email}" } af:HTTPRequest input, 
                   @af:BlobOutput { path: "images/{headers.X-ARR-LOG-ID}" } af:StringOutputBinding blob,
                   @af:QueueOutput { queueName: "requests" } af:StringOutputBinding queueOut)
                   returns @af:HTTPOutput string {
    map<json> headers = <map<json>> ctx.metadata.Headers;
    string jobId = headers["X-ARR-LOG-ID"].toString();
    string email = <string> ctx.metadata.email.toString().fromJsonString();
    blob.value = input.body;
    json jobInfo = { jobId, email };
    queueOut.value = jobInfo.toJsonString();
    return jobInfo.toJsonString();
}

@af:Function
function processImage(@af:QueueTrigger { queueName: "requests" } string queueIn,
                      @af:BlobInput { path: "images/{jobId}" } string? encodedData,
                      @af:QueueOutput { queueName: "results" } af:StringOutputBinding queueOut) 
                      returns @tainted error? {
    json jobInfo = check queueIn.fromJsonString();
    byte[] data = check array:fromBase64(encodedData.toString());
    azurecv:Client cvClient = new({ key: system:getEnv("AZURE_CV_KEY") });
    string text = check cvClient->ocr(data);
    json result = { jobInfo, text };
    queueOut.value = <@untainted> result.toJsonString();
}

@af:Function
function publishResults(@af:QueueTrigger { queueName: "results" } string queueIn) returns error? {
    json result = check queueIn.fromJsonString();
    check sendEmail(result.jobInfo.jobId.toString(), result.jobInfo.email.toString(), result.text.toString());
}

public function sendEmail(string jobId, string email, string text) returns error? {
    gmail:GmailConfiguration gmailConfig = {
        oauthClientConfig: {
            accessToken: system:getEnv("GMAIL_ACCESS_TOKEN"),
            refreshConfig: {
                refreshUrl: gmail:REFRESH_URL,
                refreshToken: system:getEnv("GMAIL_REFRESH_TOKEN"),
                clientId: system:getEnv("GMAIL_CLIENT_ID"),
                clientSecret: system:getEnv("GMAIL_CLIENT_SECRET")
            }
        }
    };
    gmail:Client gmailClient = new (gmailConfig);
    gmail:MessageRequest messageRequest = {};
    messageRequest.recipient = email;
    messageRequest.sender = "lafernando@gmail.com";
    messageRequest.subject = "OCR Result for Job: " + jobId;
    messageRequest.messageBody = text;
    messageRequest.contentType = gmail:TEXT_PLAIN;
    _ = check gmailClient->sendMessage("me", messageRequest);
}
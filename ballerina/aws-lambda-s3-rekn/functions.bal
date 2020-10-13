import ballerina/system;
import ballerinax/awslambda;
import wso2/amazonrekn;
import ballerinax/googleapis.gmail version 0.12.0;

@awslambda:Function
public function processImage(awslambda:Context ctx, awslambda:S3Event event) returns @tainted error? {
    amazonrekn:Client reknClient = new({accessKey: system:getEnv("AWS_AK"), 
                                        secretKey: system:getEnv("AWS_SK"),
                                        region: "us-west-1"});
    foreach var entry in event.Records {
        var result = check reknClient->detectLabels({bucket: entry.s3.bucket.name, 
                                                     name: entry.s3.'object.key});
        string content = result.reduce(function (string x, amazonrekn:Label label) returns string => x + 
                                       string `<tr><td>${label.name}</td><td>${label.confidence}</td></tr>`, 
                                       "<table><tr><th>Label</th><th>Confidence</th></tr>") + "</table>";
        check sendEmail(entry.s3.'object.key, content);
    }
}

public function sendEmail(string key, string text) returns @tainted error? {
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
    messageRequest.recipient = system:getEnv("EMAIL");
    messageRequest.sender = system:getEnv("EMAIL");
    messageRequest.subject = "Image Analysis for '" + key + "'";
    messageRequest.messageBody = text;
    messageRequest.contentType = gmail:TEXT_HTML;
    _ = check gmailClient->sendMessage("me", messageRequest);
}

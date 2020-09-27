import ballerinax/awslambda;
import ballerina/system;
import laf/aws.stepfuncs;
import ballerinax/googleapis.gmail version 0.12.0;
import ballerina/encoding;

public type LeaveRequest record {
    string employeeId;
    string date;
};

public type LeaveRequestResult record {
    *LeaveRequest;
    string decision;
    string taskToken;
};

public type Employee record {
    string name;
    string email;
    string leadId;
};

public type LeaveRequestTask record {
    LeaveRequest req;
    string token;
};

map<Employee> employees = { 
    "E001": { name: "John Carpenter", email: "lafernando@gmail.com", leadId: "" },
    "E002": { name: "Jim O'Dell", email: "lafernando@gmail.com", leadId: "E001" },
    "E003": { name: "Jane Cook", email: "jane@foo.com", leadId: "E001" }
};

stepfuncs:Client stepfuncsClient = new({accessKey: system:getEnv("AWS_AK"), secretKey: 
                                        system:getEnv("AWS_SK"), region: "us-west-1"});

@awslambda:Function
public function requestLeave(awslambda:Context ctx, json req) returns json|error {
    string leaveRequestSMArn = system:getEnv("LEAVE_REQUEST_SM_ARN");
    var result = check stepfuncsClient->startExecution(leaveRequestSMArn, req);
    return { status: "Leave request submitted", ref: result.executionArn };
}

@awslambda:Function
public function processLeaveRequest(awslambda:Context ctx, LeaveRequestTask task) returns error? {
    string empId = task.req.employeeId;
    string date = task.req.date;
    string taskToken = check encoding:encodeUriComponent(task.token, "UTF-8");
    string leaveLeadRespURL = system:getEnv("LEAVE_LEAD_RESP_URL");
    string? leadEmail = employees[employees[empId]?.leadId.toString()]?.email;
    if leadEmail is string {
        string body = string `<a href="${leaveLeadRespURL}/${empId}/${date}/approved/${taskToken}">Approve</a> or 
                              <a href="${leaveLeadRespURL}/${empId}/${date}/denied/${taskToken}">Deny</a>?`;
        check sendEmail(leadEmail, string `Leave Request from ${
                        employees[empId]?.name.toString()} for ${date}`, body);
    }
}

@awslambda:Function
public function submitLeadResponse(awslambda:Context ctx, LeaveRequestResult result) returns error? {
    result.taskToken = check encoding:decodeUriComponent(result.taskToken, "UTF-8");
    check stepfuncsClient->sendTaskSuccess(result.taskToken, check json.constructFrom(result));
}

@awslambda:Function
public function processLeadLeaveResponse(awslambda:Context ctx, LeaveRequestResult result) returns error? {
    string? address = employees[result.employeeId]?.email;
    if address is string {
        check sendEmail(address, string `You leave request for ${result.date} has been ${result.decision}!`, 
                        "$subject.");
    }
}

public function sendEmail(string address, string subject, string text) returns error? {
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
    messageRequest.recipient = address;
    messageRequest.sender = "admin@foo.com";
    messageRequest.subject = subject;
    messageRequest.messageBody = text;
    messageRequest.contentType = gmail:TEXT_HTML;
    var result = gmailClient->sendMessage("me", messageRequest);
    if result is error {
        return <@untainted> result;
    }
}
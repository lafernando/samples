import ballerinax/awslambda;
import ballerina/system;
import laf/aws.stepfuncs;
import ballerinax/googleapis.gmail version 0.12.0;

public type LeaveRequest record {
    string employeeId;
    string date;
};

public type LeaveRequestResult record {
    *LeaveRequest;
    boolean approved;
    string taskToken;
};

public type Employee record {
    string name;
    string email;
    string leadId;
};

public type LeaveRequestTask record {
    LeaveRequest Input;
    string TaskToken;
};

const LEAVE_REQUEST_SM_ARN = "arn:aws:states:us-west-1:908363916138:stateMachine:EmployeeLeaveWorkflow";

map<Employee> employees = { 
    "E001": { name: "John Carpenter", email: "john@foo.com", leadId: "" },
    "E002": { name: "Jim O'Dell", email: "jim@foo.com", leadId: "E001" },
    "E003": { name: "Jane Cook", email: "jane@foo.com", leadId: "E001" }
};

stepfuncs:Client stepfuncsClient = new({accessKey: system:getEnv("AWS_AK"), secretKey: 
                                        system:getEnv("AWS_SK"), region: "us-west-1"});

@awslambda:Function
public function requestLeave(awslambda:Context ctx, LeaveRequest req) returns json|error {
    json input = check json.constructFrom(req);
    var result = check stepfuncsClient->startExecution(LEAVE_REQUEST_SM_ARN, input);
    return json.constructFrom(result);
}

@awslambda:Function
public function processLeaveRequest(awslambda:Context ctx, LeaveRequestTask req) returns error? {
    string empId = req.Input.employeeId;
    string? leadEmail = employees[employees[empId]?.leadId.toString()]?.email;
    if leadEmail is string {
        string body = string `<a href="https://google.com/approve_leave">Approve</a> or 
                              <a href="https://google.com/deny_leave">Deny</a> leave?`;
        check sendEmail(leadEmail, string `Leave Request from ${
                        employees[empId]?.name.toString()}`, body);
    }
}

@awslambda:Function
public function submitLeadResponse(awslambda:Context ctx, LeaveRequestResult result) returns json|error {
    check stepfuncsClient->sendTaskSuccess(result.taskToken, { status: result.approved ? 
                                           "Approved" : "Denied" });
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
import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/system;
import ballerina/math;
import ballerina/runtime;

type ApplicationInfo object {
    string name;
    string ssn;
    float loan_amount;
    string zipcode;
    float income;
    boolean married;
};

type ApplicationEntry object {
    string state = "RISK_ASSESMENT";
    string comment = "";
    string appid;
    ApplicationInfo appinfo;
};

type ApplicationReview object {
    string appid;
    string result;
    string comment;
};

channel<json> reviewChannel;

map<ApplicationEntry> applications;

service<http:Service> LoanService bind { port: 9090 } {    

    @http:ResourceConfig {
        body: "appinfo",
        methods: ["POST"],
        path: "/application"
    }
    start_application (endpoint caller, http:Request request, ApplicationInfo appinfo) {
        string appid = generateApplicationID();
        _ = caller->respond({"ApplicationID" : appid}) but { 
                            error e => log:printError("Error sending response", err = e) };
        processApplication(appid, appinfo);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/application/{applicationID}"
    }
    get_application (endpoint caller, http:Request request, string applicationID) {
        ApplicationEntry? entry = applications[applicationID];
        _ = caller->respond(check <json> entry) but { 
                            error e => log:printError("Error sending response", err = e) };
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/application/"
    }
    get_all_applications (endpoint caller, http:Request request, string applicationID) {
        _ = caller->respond(check <json> applications) but { 
                            error e => log:printError("Error sending response", err = e) };
    }
    
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/application_review/",
        body: "applicationReview"
    }
    add_application_review (endpoint caller, http:Request request, ApplicationReview applicationReview) {
        json message = check <json> applicationReview;
        _ = caller->respond({"Stats" : "Submit Review", "ApplicationID" : untaint applicationReview.appid,
                            "Message" : untaint message}) but { error e => log:printError("Error sending response", err = e) };

        message -> reviewChannel, applicationReview.appid;            
    }

}

function generateApplicationID() returns string {
    return system:uuid();
}

function lookupCreditScore(string ssn) returns float {
    return math:random() * 850.0;
}

function approveApplication(ApplicationEntry entry, string reason) {
    entry.state = "APPROVED";
    entry.comment = reason;
    io:println("Loan Application Approved: ", entry.appid, ", Comment: ", entry.comment);
}

function denyApplication(ApplicationEntry entry, string reason) {
    entry.state = "DENIED";
    entry.comment = reason;
    io:println("Loan Application Denied: ", entry.appid, ", Comment: ", entry.comment);
}

function processReviewApplication(ApplicationEntry entry) {
    entry.state = "IN-REVIEW";
    json message;
    // Wait for review decision. These channel receives are used to wait for external 
    // triggers to be sent to the process to continue the execution
    message <- reviewChannel, entry.appid;
    string result = check <string> message.result;
    string comment = check <string> message.comment;
    io:println("Review Received: " + result, ", Message: ", comment);
    if (result == "APPROVED") {
        approveApplication(entry, comment);
    } else {
        denyApplication(entry, comment);
    }
}

function processApplication(string appid, ApplicationInfo appinfo) {
    // Create and store the application 
    ApplicationEntry entry = new;
    entry.appid = appid;
    entry.appinfo = appinfo;
    applications[appid] = entry;
    io:println("New Application: ", check <json> appinfo, " ApplicationID: ", appid);

    // Check credit score for risk analysis
    float credit_score = lookupCreditScore(appinfo.ssn);
    io:println("Credit Score: ", credit_score);
   
    if (credit_score >= 690) {
        // Good credit score, we will immediately approve this
        io:println("Good Credit Score, Loan Approved Immediately.");
        approveApplication(entry, "Good Credit Score");
    } else {
        // Not-so-good, a human will review the application
        io:println("Credit Score Questionable, Loan In Review State.");
        processReviewApplication(entry);
    }
}
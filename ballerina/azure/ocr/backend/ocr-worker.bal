import ballerina/io;
import ballerina/system;
import ballerina/runtime;
import ballerina/http;
import ballerina/config;
import wso2/azureblob;
import wso2/azurequeue;

azureblob:Configuration blobConfig = {
    accessKey: config:getAsString("ACCESS_KEY"),
    account: config:getAsString("ACCOUNT")
};

azurequeue:Configuration queueConfig = {
    accessKey: config:getAsString("ACCESS_KEY2"),
    account: config:getAsString("ACCOUNT2")
};

azureblob:Client blobClient = new(blobConfig);
azurequeue:Client queueClient = new(queueConfig);

public function main() {
    io:println("Worker Starting...");

    while (true) {
        var result = retrieveJob();
        if (result is error) {
            io:println(result);
        } else if (result is ()) {
            // if no jobs, sleep a bit
            runtime:sleep(2000);
        } else {
            processJob(result[1], result[2]);
            jobDone(result[0], result[3], result[4]);
            io:println("Job Done: " + result[0]);
        }
    }
}

public function processJob(byte[] data, string email) {
    io:println("Job Process:- ");
    io:println("DATA LENGTH: ", data.length());
    io:println("EMAIL: ", email);
    
}

public function retrieveJob() returns (string, byte[], string, string, string)|error|() {
    var result = queueClient->getMessages("queue1");
    if (result is azurequeue:GetMessagesResult) {
        if (result.messages.length() > 0) {
            string msg = result.messages[0].messageText;
            string messageId = result.messages[0].messageId;
            string popReceipt = result.messages[0].popReceipt;
            string[] msgItems = msg.split(":");
            string jobId = msgItems[0];
            string email = msgItems[1];
            var br = blobClient->getBlob("ctn1", jobId);
            if (br is azureblob:BlobResult) {
                var data = br.data;
                if (data is byte[]) {
                    return (jobId, data, email, messageId, popReceipt);
                } else {
                    // cleanup the inconsistent state
                    jobDone(jobId, messageId, popReceipt);
                    return ();
                }
            } else {
                // cleanup the inconsistent state
                jobDone(jobId, messageId, popReceipt);
                return ();
            }
        } else {
            return ();
        }
    } else {
        return result;
    }
}

public function jobDone(string jobId, string messageId, string popReceipt) {
    var qr = queueClient->deleteMessage("queue1", messageId, popReceipt);
    if (qr is ()) {
        io:println("Job Message Deleted: ", jobId);
        var br = blobClient->deleteBlob("ctn1", jobId);
        if (br is ()) {
            io:println("Job Data Deleted: ", jobId);
        }
    }
}

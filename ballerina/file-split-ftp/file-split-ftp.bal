import ballerina/file;
import ballerina/log;
import ballerina/io;
import ballerina/config;
import wso2/ftp;
import wso2/gmail;

listener file:Listener filein = new ({
    path: "/tmp/in"
});

ftp:ClientEndpointConfig ftpConfig = {
    protocol: ftp:FTP,
    host: config:getAsString("ftp_host"),
    port: 20,
    secureSocket: {
        basicAuth: {
            username: config:getAsString("ftp_user"),
            password: config:getAsString("ftp_pass")
        }
    }
};

ftp:Client ftpClient = new(ftpConfig);

gmail:GmailConfiguration gmailConfig = {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            config: {
                grantType: http:DIRECT_TOKEN,
                config: {
                    accessToken: config:getAsString("gmail_at"),
                    refreshConfig: {
                        refreshUrl: gmail:REFRESH_URL,
                        refreshToken: config:getAsString("gmail_rt"),
                        clientId: config:getAsString("gmail_clientid"),
                        clientSecret: config:getAsString("gmail_clientsecret")
                    }
                }
            }
        }
    }
};

gmail:Client gmailClient = new(gmailConfig);

service file_reader on filein {
    resource function onCreate(file:FileEvent fe) returns error? {
        if (fe.name.endsWith(".txt")) {
            io:println("File: ", fe.name);
            check processFileData(<@untainted> fe);
            check ftpFiles();
            check sendDoneEmail();
        }
    }
}

function processFileData(file:FileEvent fe) returns error? {
    io:ReadableByteChannel bch = check io:openReadableFile("/tmp/in/" + fe.name);
    io:ReadableCharacterChannel cch = new(bch, "UTF-8");
    io:ReadableTextRecordChannel rch = new(cch, rs = "\n", fs = "*");
    while (rch.hasNext()) {
        string[] line = check rch.getNext();
        check writeFileLine("/tmp/out/" + line[0], line);
    }
}

function writeFileLine(string path, string[] line) returns error? {
    io:WritableByteChannel bch = check io:openWritableFile(path);
    io:WritableDataChannel dch = new(bch);
    string linex = "".'join(...line);
    check dch.writeString(linex, "UTF-8");
}

function ftpFiles() returns error? { 
    check ftpFile("/tmp/out/1.txt", "/data/1.txt");
    check ftpFile("/tmp/out/2.txt", "/data/2.txt");
    check ftpFile("/tmp/out/3.txt", "/data/3.txt");
}

function ftpFile(string src, string tgt) returns error? {
    io:ReadableByteChannel bch = check io:openReadableFile(src);
    check ftpClient.append(tgt, bch);
}

function sendDoneEmail() returns error? {
    gmail:MessageRequest messageRequest = {};
    messageRequest.recipient = "admin@acme.com";
    messageRequest.sender = "foo@acme.com";
    messageRequest.subject = "File Integration Executed";
    messageRequest.messageBody = "File Integration Done with FTP transfers";
    messageRequest.contentType = gmail:TEXT_PLAIN;
    check gmailClient->sendMessage("foo", messageRequest);
}
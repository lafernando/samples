import ballerina/http;
import ballerinax/java.jdbc;
import ballerina/system;
import ballerina/jsonutils;
import ballerina/lang.'decimal as decimals;
import ballerina/io;

public type ACCOUNT_STATE "ACTIVE"|"FROZEN"|"CLOSED";

public type Account record {|
    string accountId = "";
    string name;
    string address;
    string balance;
    ACCOUNT_STATE state = "ACTIVE";
    string branchId;
|};

public type LogEntry record {|
    string accountId;
    string eventType;
    string eventPayload;
|};

jdbc:Client db = new ({
    url: "jdbc:mysql://localhost:3306/BANKING_DB?serverTimezone=UTC",
    username: "root",
    password: "root"
});

type CommandHandler function (string, json) returns error?;

map<CommandHandler> handlers = {};

function createAccountHandler(string accountId, json event) returns error? {
    Account account = check Account.constructFrom(event);
    _ = check db->update("INSERT INTO ACCOUNT (accountId, name, address, balance, state, branchId) " +
                         "VALUES (?,?,?,?,?,?)", account.accountId, account.name, account.address, 
                         check decimals:fromString(account.balance), account.state, account.branchId);
}

function freezeAccountHandler(string accountId, json event) returns error? {
    _ = check db->update("UPDATE ACCOUNT SET state = ? WHERE accountId = ?", "FROZEN", accountId);
}

function closeAccountHandler(string accountId, json event) returns error? {
    _ = check db->update("UPDATE ACCOUNT SET state = ? WHERE accountId = ?", "CLOSED", accountId);
}

function creditAccountHandler(string accountId, json event) returns error? {
    _ = check db->update("UPDATE ACCOUNT SET balance = balance + ? WHERE accountId = ?", 
                          check decimals:fromString(event.toString()), accountId);
}

function debitAccountHandler(string accountId, json event) returns error? {
    _ = check db->update("UPDATE ACCOUNT SET balance = balance - ? WHERE accountId = ?", 
                          check decimals:fromString(event.toString()), accountId);
}

public function main() returns @tainted error? {
    handlers["CreateAccount"] = createAccountHandler;
    handlers["FreezeAccount"] = freezeAccountHandler;
    handlers["CloseAccount"] = closeAccountHandler;
    handlers["CreditAccount"] = creditAccountHandler;
    handlers["DebitAccount"] = debitAccountHandler;
    check refreshAccountActiveRatios();
}

function refreshAccountActiveRatios() returns @tainted error? {
    _ = check db->call("CALL RefreshAccountActiveRatios()", ());
}

function dispatchCommand(string accountId, string eventType, json event) returns error? {
    CommandHandler? handler = handlers[eventType];
    if handler is CommandHandler {
        check handler(accountId, event);
    }
}

function saveEvent(string accountId, string eventType, json eventPayload) returns error? {
    _ = check db->update("INSERT INTO ACCOUNT_LOG (accountId, eventType, eventPayload) " +
                         "VALUES (?,?,?)", accountId, eventType, eventPayload.toJsonString());
}

function executeCommandAndLogEvent(string accountId, string name, json event) returns error? {
    error? result;
    transaction {
        result = dispatchCommand(accountId, name, event);
        if result is error {
            abort;
        }
        result = saveEvent(accountId, name, event);
        if result is error {
            abort;
        }
    }
    return result;
}

function parseJson(string str) returns json|error {
    io:StringReader sr = new(str, encoding = "UTF-8");
    return check <@untainted> sr.readJson();
}

function replayLog(string accountId) returns @tainted error? {
    var result = check db->select("SELECT accountId, eventType, eventPayload FROM ACCOUNT_LOG WHERE accountId = ?", 
                                   LogEntry, accountId);
    foreach LogEntry entry in <table<LogEntry>> result {
        check dispatchCommand(entry.accountId, entry.eventType, check parseJson(entry.eventPayload));
    }
}

service AccountManagement on new http:Listener(8080) {

    @http:ResourceConfig {
        methods: ["POST"],
        body: "account"
    }
    resource function createAccount(http:Caller caller, http:Request request, Account account) returns error? {
        account.accountId = system:uuid();
        json event = check json.constructFrom(<@untainted> account);
        check executeCommandAndLogEvent(account.accountId, "CreateAccount", event);
        check caller->respond(event);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "freezeAccount/{accountId}"
    }
    resource function freezeAccount(http:Caller caller, http:Request request, string accountId) returns error? {
        json event = { "reason" : check <@untainted> request.getTextPayload() };
        check executeCommandAndLogEvent(accountId, "FreezeAccount", event);
        check caller->respond(event);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "closeAccount/{accountId}"
    }
    resource function closeAccount(http:Caller caller, http:Request request, string accountId) returns error? {
        json event = { "reason" : check <@untainted> request.getTextPayload() };
        check executeCommandAndLogEvent(accountId, "CloseAccount", event);
        check caller->respond(event);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "creditAccount/{accountId}"
    }
    resource function creditAccount(http:Caller caller, http:Request request, string accountId) returns @untainted error? {
        json event = check request.getTextPayload();
        check executeCommandAndLogEvent(accountId, "CreditAccount", event);
        check caller->respond();
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "debitAccount/{accountId}"
    }
    resource function debitAccount(http:Caller caller, http:Request request, string accountId) returns @untainted error? {
        json event = check request.getTextPayload();
        check executeCommandAndLogEvent(accountId, "DebitAccount", event);
        check caller->respond();
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "getAccountDetails/{accountId}"
    }
    resource function getAccountDetails(http:Caller caller, http:Request request, string accountId) returns @tainted error? {
        var result = check db->select("SELECT * FROM ACCOUNT WHERE accountId = ?", Account, <@untainted> accountId);
        check caller->respond(jsonutils:fromTable(result));
    }

    @http:ResourceConfig {
        methods: ["GET"]
    }
    resource function getAccountActiveRatios(http:Caller caller, http:Request request) returns @tainted error? {
        var result = check db->select("SELECT * FROM ACCOUNT_ACTIVE_RATIO", ());
        check caller->respond(jsonutils:fromTable(result));
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "replayLog/{accountId}"
    }
    resource function replayLog(http:Caller caller, http:Request request, string accountId) returns @tainted error? {
        check replayLog(accountId);
        check caller->respond();
    }

}

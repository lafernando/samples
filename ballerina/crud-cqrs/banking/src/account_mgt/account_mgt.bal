import ballerina/http;
import ballerinax/java.jdbc;
import ballerina/system;
import ballerina/jsonutils;
import ballerina/lang.'decimal as decimals;

public type Account record {|
    string accountId = "";
    string name;
    string address;
    string balance;
    ACCOUNT_STATE state = "ACTIVE";
    string branchId;
|};

public type ACCOUNT_STATE "ACTIVE"|"FROZEN"|"CLOSED";

jdbc:Client db = new ({
    url: "jdbc:mysql://localhost:3306/BANKING_DB?serverTimezone=UTC",
    username: "root",
    password: "root"
});

type CommandHandler function (json) returns error?;

map<CommandHandler> handlers = {};

public function createAccountHandler(json event) returns error? {
    Account account = check Account.constructFrom(event);
    _ = check db->update("INSERT INTO ACCOUNT (account_id, name, address, balance, state, branch_id) " +
                         "VALUES (?,?,?,?,?,?)", account.accountId, account.name, account.address, 
                         check decimals:fromString(account.balance), account.state, account.branchId);
}

public function main() {
    handlers["CreateAccount"] = createAccountHandler;
}

public function dispatchCommand(string name, json event) returns error? {
    CommandHandler? handler = handlers[name];
    if handler is CommandHandler {
        check handler(event);
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
        check dispatchCommand("CreateAccount", event);
        check caller->respond(event);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "getAccountDetails/{accountId}"
    }
    resource function getAccountDetails(http:Caller caller, http:Request request, string accountId) returns @tainted error? {
        var result = check db->select("SELECT * FROM ACCOUNT WHERE account_id = ?", Account, <@untainted> accountId);
        check caller->respond(jsonutils:fromTable(result));
    }

}

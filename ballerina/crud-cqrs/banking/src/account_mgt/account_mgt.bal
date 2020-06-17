import ballerina/http;
import ballerinax/java.jdbc;
import ballerina/system;

public type Account record {|
    string accountId = "";
    string name;
    string address;
    decimal balance;
    string state;
    string branchId;
|};

jdbc:Client db = new ({
    url: "jdbc:mysql://localhost:3306/BANKING_DB?serverTimezone=UTC",
    username: "root",
    password: "root"
});

service AccountManagement on new http:Listener(8080) {

    @http:ResourceConfig {
        path: "/create_account",
        methods: ["POST"],
        body: "account"
    }
    resource function createAccount(http:Caller caller, http:Request request, Account account) returns error? {
        account.accountId = system:uuid();
        _ = check db->update("INSERT INTO Account (account_id, name, address, balance, state, branch_id) " +
                              "VALUES (?,?,?,?,?,?)", account.accountId, account.name, account.address, 
                              account.balance, account.state, account.branchId);
        check caller->respond(check json.constructFrom(<@untainted> account));
    }

}

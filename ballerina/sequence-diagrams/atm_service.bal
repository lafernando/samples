import ballerinax/java.jdbc;
import ballerina/http;

jdbc:Client accountsDB = new({
    url: "jdbc:mysql://dbhost/accounts",
    username: "user",
    password: "pass"
});

type Account record {
    string id;
    string name;
    decimal balance;
};

service ATMService on new http:Listener(80) {

    @http:ResourceConfig {
        path: "/{id}/{val}"
    }
    resource function withdrawMoney(http:Caller caller, http:Request request, 
                                    string id, decimal val) returns @tainted error? {
        decimal balance = check checkBalance(id);
        if balance < val {
            var result = check caller->respond("Fail: no funds");
        } else {
            check debitAccount(id, val);
            var result = check caller->respond("Success");
        }
    }
}

public function checkBalance(string id) returns @tainted error|decimal {
    var selectRet = check accountsDB->select("SELECT balance FROM Account WHERE id = ?", 
                                         Account, id);
    decimal balance = 1000.0;
    return balance;
}

public function debitAccount(string accountId, decimal balance) returns error? {
    _ = check accountsDB->update("UPDATE Account SET balance = ? WHERE id = ?", 
                             balance, accountId);
}

public function initSystem(http:Client lookupService, http:Client reportService) {
    worker proc1 {
        // process something
        var res1 = lookupService->get("/query");
        int x = 0;
        foreach var i in 1...10 { x += i; }
        x -> proc2;
        x = <- proc2;
        http:Request req = new;
        var res2 = reportService->post("/report", req);
    }
    worker proc2 {
        // process other things
        int x = 1;
        int i = 1;
        while i < 10 { x *= i; }
        x = <- proc1;
        var res1 = lookupService->get("/query");
        // process more
        x -> proc1;
    }
}

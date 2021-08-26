import ballerina/http;
import ballerinax/java.jdbc;
import ballerina/jsonutils;

jdbc:Client dbClient = new ({
    url: "jdbc:mysql://localhost:3306/ECOM_DB?serverTimezone=UTC",
    username: "root",
    password: "root"
});

service Inventory on new http:Listener(8084) {

    @http:ResourceConfig {
        path: "/search/{query}",
        methods: ["GET"]
    }
    resource function search(http:Caller caller, http:Request request, 
                             string query) returns @tainted error? {
        var rs = check dbClient->select("SELECT id, description FROM ECOM_INVENTORY WHERE description LIKE '%" + 
                                        <@untainted> query + "%'", ());
        check caller->respond(jsonutils:fromTable(rs));
    }

}
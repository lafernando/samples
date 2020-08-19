import ballerina/http;
import ballerina/java.jdbc;
import ballerina/sql;

jdbc:Client empDB = check new ("jdbc:mysql://localhost:3306/Employee", "root", "root");

@http:ServiceConfig { 
    basePath: "/data" 
}
service employeeDS on new http:Listener(8080) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/employees"
    }
    resource function getEmployees(http:Caller caller, http:Request req) returns error? {
        stream<record{}, error> entries = <@untainted> empDB->query("SELECT * FROM Employee", Employee);
        json result = check from var entry in entries select entry.toJson();
        check caller->respond(result);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/employees/{id}"
    }
    resource function getEmployeeById(http:Caller caller, http:Request req, int id) returns error? {
        stream<record{}, error> entries = <@untainted> empDB->query(
            `SELECT * FROM Employee WHERE id = ${<@untainted> id}`, Employee);
        check caller->respond((check entries.next()).toJson());
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/employees",
        body: "payload"
    }
    resource function addEmployee(http:Caller caller, http:Request req,
                                  Employee payload) returns error? {
        Employee emp = <@untainted> payload;
        _ = check empDB->execute(`INSERT INTO Employee VALUES (${emp.id}, 
                                 ${emp.name}, ${emp.age}, ${emp.team})`);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/employees_batch",
        body: "payload"
    }
    resource function addEmployeeBatch(http:Caller caller, http:Request req,
                                       Employee[] payload) returns error? {
        sql:ParameterizedQuery[] batchQuery = <@untainted> from var emp in payload
            select `INSERT INTO Employee VALUES (${emp.id}, ${emp.name},
            ${emp.age}, ${emp.team})`;
        _ = check empDB->batchExecute(batchQuery);
    }

    @http:ResourceConfig {
        methods: ["PUT"],
        path: "/employees",
        body: "payload"
    }
    resource function updateEmployee(http:Caller caller, http:Request req, Employee payload) {
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/employees/{id}"
    }
    resource function deleteEmployee(http:Caller caller, http:Request req, int id) {
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/employee_team_swap/{id1}/{id2}"
    }
    resource function swapEmployeeTeams(http:Caller caller, http:Request req, int id1, int id2) returns error? {
        transaction {
            stream<record{}, error> res1 = <@untainted> empDB->query(`SELECT team FROM Employee WHERE id = ${<@untainted> id1}`);
            stream<record{}, error> res2 = <@untainted> empDB->query(`SELECT team FROM Employee WHERE id = ${<@untainted> id2}`);
            record{string team;}? emp1 = <record{string team;}?> res1.next();
            record{string team;}? emp2 = <record{string team;}?> res2.next();
            if !(emp1 is () || emp2 is ()) {
                _ = check empDB->execute(`UPDATE Employee SET team = ${emp2.team} WHERE id = ${<@untainted> id1}`);
                _ = check empDB->execute(`UPDATE Employee SET team = ${emp1.team} WHERE id = ${<@untainted> id2}`);
            }
            check commit;
        }
    }

}

type Employee record {|
    int id;
    string name;
    int age;
    string team;
|};

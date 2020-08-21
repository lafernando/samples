import ballerina/http;
import ballerina/java.jdbc;
import ballerina/sql;

jdbc:Client empDB = check new ("jdbc:mysql://localhost:3306/EmpDB?serverTimezone=UTC", "root", "root");

type Employee record {|
    int id;
    string name;
    int age;
    string team;
|};

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
        check caller->ok();
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
        check caller->ok();
    }

    @http:ResourceConfig {
        methods: ["PUT"],
        path: "/employees",
        body: "payload"
    }
    resource function updateEmployee(http:Caller caller, http:Request req, Employee payload) returns error? {
        Employee emp = <@untainted> payload;
        _ = check empDB->execute(`UPDATE Employee SET name=${emp.name}, 
                                  age=${emp.age}, team=${emp.team} WHERE id=${emp.id}`);
        check caller->ok();
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/employees/{id}"
    }
    resource function deleteEmployee(http:Caller caller, http:Request req, int id) returns error? {
        _ = check empDB->execute(`DELETE FROM Employee WHERE id=${<@untainted> id}`);
        check caller->ok();
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/employee_team_swap/{id1}/{id2}"
    }
    resource function swapEmployeeTeams(http:Caller caller, http:Request req, int id1, int id2) returns error? {
        transaction {
            stream<record{}, error> res1 = <@untainted> empDB->query(`SELECT team FROM Employee WHERE id = ${<@untainted> id1}`);
            stream<record{}, error> res2 = <@untainted> empDB->query(`SELECT team FROM Employee WHERE id = ${<@untainted> id2}`);
            record {|record {} value;|}|error? emp1 = res1.next();
            record {|record {} value;|}|error? emp2 = res2.next();
            if emp1 is record {|record {} value;|} && emp2 is record {|record {} value;|} {
                _ = check empDB->execute(`UPDATE Employee SET team = ${<string> emp2.value["team"]} WHERE id = ${<@untainted> id1}`);
                _ = check empDB->execute(`UPDATE Employee SET team = ${<string> emp1.value["team"]} WHERE id = ${<@untainted> id2}`);
            }
            check commit;
        }
        check caller->ok();
    }

}

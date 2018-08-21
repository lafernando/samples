import ballerina/http;
import ballerina/log;
import ballerina/jdbc;
import ballerina/sql;

type Employee record {
    int id;
    string name;
    int age;
};

endpoint jdbc:Client empDB {
    url: "jdbc:oracle:thin:@//localhost:1521/XE",
    username: "scott",
    password: "tiger"
};

@http:ServiceConfig { 
    basePath: "/data" 
}
service<http:Service> dataservice bind { port: 9090 } {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/employee"
    }
    employee(endpoint caller, http:Request req) {
        http:Response res = new;
        var rs = empDB->select("SELECT * FROM Employee", Employee);
        match rs {
            table<Employee> ts => res.setJsonPayload(untaint check <json> ts);
            error e => { 
                res.statusCode = 500;
                res.setPayload(untaint e.message);
            }
        }
        caller->respond(res) but { error e => log:printError("Error in sending response", err = e) };
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/employee/{id}"
    }
    employeeById(endpoint caller, http:Request req, int id) {
        http:Response res = new;
        var rs = empDB->select("SELECT * FROM Employee WHERE id = ?", Employee, id);
        match rs {
            table<Employee> ts => res.setJsonPayload(untaint check <json> ts);
            error e => { 
                res.statusCode = 500;
                res.setPayload(untaint e.message);
            }
        }
        caller->respond(res) but { error e => log:printError("Error in sending response", err = e) };
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/employee",
        body: "payload"
    }
    employeeInsert(endpoint caller, http:Request req, Employee payload) {
        http:Response res = new;
        var rs = empDB->call("CALL add_emp (?,?,?)", (), payload.id, payload.name, payload.age);
        match rs {
            table[]|() ts => res.setPayload("OK");
            error e => {
                res.statusCode = 500;
                res.setPayload(untaint e.message);
            }
        }
        caller->respond(res) but { error e => log:printError("Error in sending response", err = e) };
    }

    @http:ResourceConfig {
        methods: ["PUT"],
        path: "/employee",
        body: "payload"
    }
    employeeUpdate(endpoint caller, http:Request req, Employee payload) {
        http:Response res = new;
        var rs = empDB->update("UPDATE Employee SET name = ?, age = ? WHERE id = ?", payload.name, payload.age,
                               payload.id);
        match rs {
            int code => res.setPayload("RECORD UPDATED, CODE: " + code);
            error e => { 
                res.statusCode = 500;
                res.setPayload(untaint e.message);
            }
        }
        caller->respond(res) but { error e => log:printError("Error in sending response", err = e) };
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/employee/{id}"
    }
    employeeDelete(endpoint caller, http:Request req, int id) {
        http:Response res = new;
        var rs = empDB->update("DELETE FROM Employee WHERE id = ?", id);
        match rs {
            int code => res.setPayload("RECORD DELETED, CODE: " + code);
            error e => { 
                res.statusCode = 500;
                res.setPayload(untaint e.message);
            }
        }
        caller->respond(res) but { error e => log:printError("Error in sending response", err = e) };
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/employee_swap/{id1}/{id2}"
    }
    employeeSwapByIds(endpoint caller, http:Request req, int id1, int id2) {
        transaction {
            table<Employee> ts1 = check empDB->select("SELECT * FROM Employee WHERE id = ?", Employee, id1);
            table<Employee> ts2 = check empDB->select("SELECT * FROM Employee WHERE id = ?", Employee, id2);
            Employee e1 = check <Employee> ts1.getNext();
            Employee e2 = check <Employee> ts2.getNext();
            int tmp = e1.id;
            e1.id = e2.id;
            e2.id = tmp;
            _ = empDB->update("UPDATE Employee SET name = ?, age = ? WHERE id = ?", e1.name, e1.age, e1.id);
            _ = empDB->update("UPDATE Employee SET name = ?, age = ? WHERE id = ?", e2.name, e2.age, e2.id);
        }
        http:Response res = new;
        caller->respond(res) but { error e => log:printError("Error in sending response", err = e) };
    }

}


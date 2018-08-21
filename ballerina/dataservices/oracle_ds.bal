import ballerina/http;
import ballerina/log;
import ballerina/jdbc;
import ballerina/sql;
import ballerina/io;

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

}


import ballerina/http;

enum Major {
    CS, Physics, Chemistry
}

type Student record {
    string id;
    string name;
    Major major = CS;
};

map<Student> students = {};

service /registry on new http:Listener(8080) {

    resource function get [string id](http:Caller caller) returns error? {
        Student? student = students[id];
        if student is () {
            check self.respond(caller, "Student with the given id does not exist", 404);
        } else {
            check caller->respond(check student.cloneWithType(json));
        }
    }

    resource function post .(http:Caller caller, @http:Payload Student student) returns error? {
        if students.hasKey(student.id) {
            check self.respond(caller, "Student with the given id already exists", 400);
            return;
        } else {
            students[student.id] = student;
            check self.respond(caller, "", 200);
        }
    }

    resource function put .(http:Caller caller, @http:Payload Student student) returns error? {
        if !students.hasKey(student.id) {
            check self.respond(caller, "Student with the given id does not exist", 404);
            return;
        } else {
            students[student.id] = student;
            check self.respond(caller, "", 200);
        }
        
    }

    resource function delete [string id]() returns error? {
        _ = students.removeIfHasKey(id);
    }

    function respond(http:Caller caller, string msg, int sc) returns error? {
        http:Response resp = new;
        resp.statusCode = sc;
        resp.setTextPayload(msg);
        check caller->respond(resp);
    }

}

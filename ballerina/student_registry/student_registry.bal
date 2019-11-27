import ballerina/http;

public const CS = "CS";
public const PHYSICS = "Physics";
public const CHEMISTRY = "Chemistry";

type Major CS|PHYSICS|CHEMISTRY;

type Student record {
    string id;
    string name;
    Major major = CS;
};

map<Student> students = {};

@http:ServiceConfig {
    basePath: "/registry"
}
service StudentRegistry on new http:Listener(8080) {

    @http:ResourceConfig {
        path: "/{id}",
        methods: ["GET"]
    }
    resource function lookupStudent(http:Caller caller, http:Request request, string id) returns error? {
        check caller->respond(check json.constructFrom(students[id]));
    }

    @http:ResourceConfig {
        path: "/",
        methods: ["POST"],
        body: "student"
    }
    resource function addStudent(http:Caller caller, http:Request request, Student student) returns error? {
        if students.hasKey(student.id) {
            check self.sendBadRequest(caller, "Student with the given id already exists");
            return;
        }
        students[student.id] = student;
        check caller->ok();
    }

    @http:ResourceConfig {
        path: "/",
        methods: ["PUT"],
        body: "student"
    }
    resource function updateStudent(http:Caller caller, http:Request request, Student student) returns error? {
        if !students.hasKey(student.id) {
            check self.sendBadRequest(caller, "Student with the given id does not exist");
            return;
        }
        students[student.id] = student;
        check caller->ok();
    }

    @http:ResourceConfig {
        path: "/{id}",
        methods: ["DELETE"]
    }
    resource function deleteStudent(http:Caller caller, http:Request request, string id) returns error? {
        var res = trap students.remove(id);
        check caller->ok();
    }

    function sendBadRequest(http:Caller caller, string msg) returns error? {
        http:Response resp = new;
        resp.statusCode = 400;
        resp.setTextPayload(msg);
        check caller->respond(resp);
    }

}
import ballerina/http;

public const CS = "CS";
public const PHYSICS = "Physics";
public const CHEMISTRY = "Chemistry";

type Major CS | PHYSICS | CHEMISTRY;

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
        int x = 5;
        int a = <int>x;
        Student? student = students[id];
        if student is () {
            check self.respond(caller, "Student with the given id does not exist", 404);
        } else {
            check caller->respond(check json.constructFrom(student));
        }
    }

    @http:ResourceConfig {
        path: "/",
        methods: ["POST"],
        body: "student"
    }
    resource function addStudent(http:Caller caller, http:Request request, Student student) returns error? {
        if students.hasKey(student.id) {
            check self.respond(caller, "Student with the given id already exists", 400);
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
            check self.respond(caller, "Student with the given id does not exist", 400);
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

    function respond(http:Caller caller, string msg, int sc) returns error? {
        http:Response resp = new;
        resp.statusCode = sc;
        resp.setTextPayload(msg);
        check caller->respond(resp);
    }

}

import ballerina/http;
import ballerinax/java.jdbc;
import ballerina/system;
import ballerina/jsonutils;

public type Student record {|
    string id = "";
    string name;
    int birthYear;
    string address;
|};

jdbc:Client db = new ({
    url: "jdbc:mysql://localhost:3306/STUDENT_REG_DB?serverTimezone=UTC",
    username: "root",
    password: "root"
});

service StudentRegistry on new http:Listener(8080) {

    @http:ResourceConfig {
        path: "/student",
        methods: ["POST"],
        body: "student"
    }
    resource function addStudent(http:Caller caller, http:Request request, Student student) returns error? {
        student.id = system:uuid();
        _ = check db->update("INSERT INTO STUDENT (id, name, birthYear, address) VALUES (?,?,?,?)", 
                         student.id, student.name, student.birthYear, student.address);
        check caller->respond(check json.constructFrom(<@untainted> student));
    }

    @http:ResourceConfig {
        path: "/student/{id}",
        methods: ["GET"]
    }
    resource function getStudent(http:Caller caller, http:Request request, string id) returns @tainted error? {
        var result = check db->select("SELECT * FROM STUDENT WHERE id = ?", (), <@untainted> id);
        check caller->respond(jsonutils:fromTable(result));
    }

}
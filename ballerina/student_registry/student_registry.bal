import ballerina/http;

enum Major {
    CS, Physics, Chemistry
}

type Student record {|
    string id;
    string name;
    Major major = CS;
|};

map<Student & readonly> students = {};

service /registry on new http:Listener(8080) {

    resource function get [string id]() returns Student|http:NotFound {
        Student? student;
        lock {
            student = students[id];
        }
        if student is () {
            return {body: "Student with the given id does not exist"};
        } else {
            return student;
        }
    }

    resource function post .(@http:Payload Student student) returns http:Ok|http:BadRequest {
        lock {
            if students.hasKey(student.id) {
                return <http:BadRequest> {body: "Student with the given id already exists"};
            }   
            students[student.id] = student.cloneReadOnly(); 
        }
        return <http:Ok> {};
    }

    resource function put .(@http:Payload Student student) returns http:BadRequest|http:Ok {
        lock {
            if !students.hasKey(student.id) {
                return <http:BadRequest> {body: "Student with the given id does not exist"};
            }
            students[student.id] = student.cloneReadOnly();
        }
        return <http:Ok> {};
    }

    resource function delete [string id]() returns http:Ok {
        lock {
            _ = students.removeIfHasKey(id);
        }
        return <http:Ok> {};
    }

}

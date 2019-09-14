import ballerina/io;

type Person record {
    int id;
    string name;
    int birthyear;
};

public function main() {
    stream<Person> personStream = new;
    personStream.subscribe(onPersonEvent);
    Person e1 = { id: 1, name: "Jane", birthyear: 1990 };
    Person e2 = { id: 2, name: "Anne", birthyear: 1995 };
    Person e3 = { id: 3, name: "John", birthyear: 1886 };
    personStream.publish(e1);
    personStream.publish(e2);
    personStream.publish(e3);
}
function onPersonEvent(Person person) {
    io:println("Person event: ", person);
}
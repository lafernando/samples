import ballerina/io;
import ballerina/time;

public type Person record {
    int id;
    string name;
    int birthyear;
};

stream<Person> personStream = new;
stream<Person> adultStream = new;

function initStreamQueries() {
    time:Time time = time:currentTime();
    int currentYear = time:getYear(time);

    forever {
        from personStream where (currentYear - personStream.birthyear) >= 21
        select * => (Person[] persons) {
            foreach var p in persons {
                adultStream.publish(p);
            }
        }
    }
}

public function main() {
    initStreamQueries();
    adultStream.subscribe(onAdultPerson);
    Person e1 = { id: 1, name: "Tom", birthyear: 2005 };
    Person e2 = { id: 2, name: "Anne", birthyear: 1995 };
    Person e3 = { id: 3, name: "John", birthyear: 1886 };
    personStream.publish(e1);
    personStream.publish(e2);
    personStream.publish(e3);
}

public function onAdultPerson(Person p) {
    io:println("Adult: ", p);
}
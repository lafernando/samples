import ballerina/rabbitmq;
import ballerinax/java.jdbc;
import ballerina/http as _;

jdbc:Client dbClient = new ({
    url: "jdbc:mysql://localhost:3306/GEO_DB?serverTimezone=UTC",
    username: "root",
    password: "root"
});

@rabbitmq:ServiceConfig {
    queueConfig: {
        queueName: "geo_queue"
    }
}
service mqService on new rabbitmq:Listener({host: "localhost", port: 5672}) {

    resource function onMessage(rabbitmq:Message message) returns @tainted error? {
        json entry = check message.getJSONContent();
        _ = check dbClient->update("INSERT INTO GEO_ENTRY (lat, lng, src, address, ref) VALUES (?,?,?,?,?)", 
                                    <float> check entry.lat, <float> check entry.long, <string> check entry.src, 
                                    <string> check entry.address, entry?.ref.toString());
    }

}

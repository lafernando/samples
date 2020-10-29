import ballerinax/rabbitmq;
import ballerina/java.jdbc;

jdbc:Client dbClient = check new ("jdbc:mysql://localhost:3306/GEO_DB?serverTimezone=UTC", "root", "root");

@rabbitmq:ServiceConfig {
    queueConfig: {
        queueName: "geo_queue"
    }
}
service mqService on new rabbitmq:Listener({host: "localhost", port: 5672}) {

    resource function onMessage(rabbitmq:Message message) returns @tainted error? {
        json entry = check message.getJSONContent();
        transaction {
            _ = check dbClient->execute(`INSERT INTO GEO_ENTRY (lat, lng, src, address, ref) 
                                        VALUES (${<@untainted> <float> entry.lat},${<@untainted> <float> entry.long},
                                        ${<@untainted> <string> entry.src}, ${<@untainted> <string> entry.address},
                                        ${<@untainted> <string?> entry?.ref})`);
            _ = check dbClient->execute(`INSERT INTO GEO_AUDIT (message) VALUES (${string `STORE ${<@untainted> entry.toJsonString()}`})`);
            check commit;
        }
    }

}

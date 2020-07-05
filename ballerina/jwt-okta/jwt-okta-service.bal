import ballerina/http;
import ballerina/jwt;

jwt:InboundJwtAuthProvider jwtAuthProvider = new({
    issuer: "https://dev-611006.okta.com/oauth2/default",
    audience: "api://default",
    jwksConfig: {
        url: "https://dev-611006-admin.okta.com/oauth2/default/v1/keys",
        clientConfig: {
            secureSocket: {
                trustStore: {
                    path: "${BALLERINA_HOME}/bre/security/ballerinaKeystore.p12",
                    password: "ballerina"
                }
            }
        }
    }    
});

http:BearerAuthHandler jwtAuthHandler = new(jwtAuthProvider);

listener http:Listener httpListener = new(8080, config = {
    auth: {
        authHandlers: [jwtAuthHandler]
    },    
    secureSocket: {
        keyStore: {
            path: "${BALLERINA_HOME}/bre/security/ballerinaKeystore.p12",
            password: "ballerina"
        }
    }
});

@http:ServiceConfig {
    basePath: "/secured"
}
service echo on httpListener {

    @http:ResourceConfig {
        methods: ["GET"],
        auth: {
            scopes: ["openid"],
            enabled: true
        }
    }
    resource function hello(http:Caller caller, http:Request req) returns error? {
        check caller->respond("Hello!");
    }

}

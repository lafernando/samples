import ballerina/http;
import ballerina/jwt;
import ballerina/runtime;
import ballerina/io;

jwt:InboundJwtAuthProvider jwkAuthProvider = new ({
    issuer: "https://dev-611006.okta.com/oauth2/default",
    audience: "api://default",
    jwksConfig: {
        url: "https://dev-611006-admin.okta.com/oauth2/default/v1/keys", 
        clientConfig: {
            secureSocket: {
                trustStore: {
                    path: "/usr/lib/ballerina/distributions/jballerina-1.2.5/bre/security/ballerinaTruststore.p12",
                    password: "ballerina"
                }
            }
        }
    }
});

http:BearerAuthHandler jwtAuthHandler = new(jwkAuthProvider);

listener http:Listener httpListener = new(8080, config = {
    auth: {
        authHandlers: [jwtAuthHandler]
    },    
    secureSocket: {
        keyStore: {
            path: "/usr/lib/ballerina/distributions/jballerina-1.2.5/bre/security/ballerinaKeystore.p12",
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
            enabled: true,
            scopes: ["sx1"]
        }
    }
    resource function hello(http:Caller caller, http:Request req) returns error? {
        runtime:InvocationContext ctx = runtime:getInvocationContext();
        runtime:AuthenticationContext? authc = ctx?.authenticationContext;
        io:println("AuthX: ", authc);
        runtime:Principal prc = <runtime:Principal> ctx.get("principal");
        check caller->respond("Hello, " + prc?.username.toString() + " Claims: " + prc?.claims.toString());
    }

}

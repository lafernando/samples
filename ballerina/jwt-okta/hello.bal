import ballerina/http;
import ballerina/jwt;
import ballerina/runtime;

jwt:InboundJwtAuthProvider jwkAuthProvider = new ({
    issuer: "https://dev-611006.okta.com/oauth2/default",
    audience: "api://default",
    jwksConfig: {
        url: "https://dev-611006-admin.okta.com/oauth2/default/v1/keys", 
        clientConfig: {
            secureSocket: {
                trustStore: {
                    path: "${BALLERINA_HOME}/bre/security/ballerinaTruststore.p12",
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
            path: "${BALLERINA_HOME}/bre/security/ballerinaKeystore.p12",
            password: "ballerina"
        }
    }
});

@http:ServiceConfig {
    basePath: "/secured"
}
service HelloService on httpListener {

    @http:ResourceConfig {
        methods: ["GET"],
        auth: {
            scopes: ["greet"]
        }
    }
    resource function hello(http:Caller caller, http:Request req) returns error? {
        runtime:InvocationContext invCtx = runtime:getInvocationContext();
        runtime:AuthenticationContext? authCtx = invCtx?.authenticationContext;
        runtime:Principal? prc = invCtx?.principal;
        check caller->respond(string `Hello ${prc?.username?:"Anonymous"}, authScheme: ${authCtx?.scheme?:"N/A"} groups: ${prc?.claims["groups"].toString()}`);
    }

}

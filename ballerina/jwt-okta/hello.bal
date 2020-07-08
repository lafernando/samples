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
                    path: "truststore.p12",
                    password: "ballerina"
                }
            }
        }
    }
});

http:BearerAuthHandler jwtAuthHandler = new(jwkAuthProvider);

listener http:Listener httpsListener = new(8443, config = {
    auth: {
        authHandlers: [jwtAuthHandler]
    },    
    secureSocket: {
        keyStore: {
            path: "keystore.p12",
            password: "ballerina"
        }
    }
});

@http:ServiceConfig {
    basePath: "/secured"
}
service HelloService on httpsListener {

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
        check caller->respond(string `Hello ${prc?.username?:"Anonymous"}, authScheme: ${authCtx?.scheme?:"N/A"} groups: ${prc?.claims["groups"].toString()}\n`);
    }

}


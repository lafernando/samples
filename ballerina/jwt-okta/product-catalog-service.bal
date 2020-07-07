import ballerina/http;
import ballerina/jwt;

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

type Product record {|
    string id;
    string name;
    decimal price;
|};

map<Product> products = {};

service ProductCatalog on httpListener {

    @http:ResourceConfig {
        methods: ["POST"],
        body: "product",
        path: "product",
        auth: {
            scopes: ["products_add"]
        }
    }
    resource function addProduct(http:Caller caller, http:Request request, Product product) returns error? {
        products[product.id] = <@untainted> product;
        check caller->ok();
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "product/{id}",
        auth: {
            scopes: ["products_access"]
        }
    }
    resource function getProduct(http:Caller caller, http:Request request, string id) returns error? {
        check caller->ok(check json.constructFrom(products[id]));
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "product",
        auth: {
            scopes: ["products_access"]
        }
    }
    resource function listProducts(http:Caller caller, http:Request request) returns error? {
        check caller->ok(check json.constructFrom(products.toArray()));
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "product/{id}",
        auth: {
            scopes: ["products_delete"]
        }
    }
    resource function removeProduct(http:Caller caller, http:Request request, string id) returns error? {
        _ = products.remove(id);
        check caller->ok();
    }

}

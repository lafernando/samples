import ballerina/grpc;

public type GeoServiceBlockingClient client object {

    *grpc:AbstractClientEndpoint;

    private grpc:Client grpcClient;

    public function __init(string url, grpc:ClientConfiguration? config = ()) {
        // initialize client endpoint.
        self.grpcClient = new(url, config);
        checkpanic self.grpcClient.initStub(self, "blocking", ROOT_DESCRIPTOR, getDescriptorMap());
    }

    public remote function lookup(LookupRequest req, grpc:Headers? headers = ()) returns ([LookupResponse, grpc:Headers]|grpc:Error) {
        
        var payload = check self.grpcClient->blockingExecute("GeoService/lookup", req, headers);
        grpc:Headers resHeaders = new;
        anydata result = ();
        [result, resHeaders] = payload;
        
        return [<LookupResponse>result, resHeaders];
        
    }

    public remote function store(StoreRequest req, grpc:Headers? headers = ()) returns (grpc:Headers|grpc:Error) {
        
        var payload = check self.grpcClient->blockingExecute("GeoService/store", req, headers);
        grpc:Headers resHeaders = new;
        [_, resHeaders] = payload;
        return resHeaders;
    }

};

public type GeoServiceClient client object {

    *grpc:AbstractClientEndpoint;

    private grpc:Client grpcClient;

    public function __init(string url, grpc:ClientConfiguration? config = ()) {
        // initialize client endpoint.
        self.grpcClient = new(url, config);
        checkpanic self.grpcClient.initStub(self, "non-blocking", ROOT_DESCRIPTOR, getDescriptorMap());
    }

    public remote function lookup(LookupRequest req, service msgListener, grpc:Headers? headers = ()) returns (grpc:Error?) {
        
        return self.grpcClient->nonBlockingExecute("GeoService/lookup", req, msgListener, headers);
    }

    public remote function store(StoreRequest req, service msgListener, grpc:Headers? headers = ()) returns (grpc:Error?) {
        
        return self.grpcClient->nonBlockingExecute("GeoService/store", req, msgListener, headers);
    }

};

public type StoreRequest record {|
    float lat = 0.0;
    float long = 0.0;
    string src = "";
    string address = "";
    string ref = "";
    
|};


public type LookupRequest record {|
    float lat = 0.0;
    float long = 0.0;
    
|};


public type LookupResponse record {|
    string address = "";
    
|};


public type Empty record {|
    
|};



const string ROOT_DESCRIPTOR = "0A1167656F5F736572766963652E70726F746F1A1B676F6F676C652F70726F746F6275662F656D7074792E70726F746F22720A0C53746F72655265717565737412100A036C617418012001280152036C617412120A046C6F6E6718022001280152046C6F6E6712100A03737263180320012809520373726312180A076164647265737318042001280952076164647265737312100A03726566180520012809520372656622350A0D4C6F6F6B75705265717565737412100A036C617418012001280152036C617412120A046C6F6E6718022001280152046C6F6E67222A0A0E4C6F6F6B7570526573706F6E736512180A076164647265737318012001280952076164647265737332670A0A47656F5365727669636512290A066C6F6F6B7570120E2E4C6F6F6B7570526571756573741A0F2E4C6F6F6B7570526573706F6E7365122E0A0573746F7265120D2E53746F7265526571756573741A162E676F6F676C652E70726F746F6275662E456D707479620670726F746F33";
function getDescriptorMap() returns map<string> {
    return {
        "geo_service.proto":"0A1167656F5F736572766963652E70726F746F1A1B676F6F676C652F70726F746F6275662F656D7074792E70726F746F22720A0C53746F72655265717565737412100A036C617418012001280152036C617412120A046C6F6E6718022001280152046C6F6E6712100A03737263180320012809520373726312180A076164647265737318042001280952076164647265737312100A03726566180520012809520372656622350A0D4C6F6F6B75705265717565737412100A036C617418012001280152036C617412120A046C6F6E6718022001280152046C6F6E67222A0A0E4C6F6F6B7570526573706F6E736512180A076164647265737318012001280952076164647265737332670A0A47656F5365727669636512290A066C6F6F6B7570120E2E4C6F6F6B7570526571756573741A0F2E4C6F6F6B7570526573706F6E7365122E0A0573746F7265120D2E53746F7265526571756573741A162E676F6F676C652E70726F746F6275662E456D707479620670726F746F33",
        "google/protobuf/empty.proto":"0A1B676F6F676C652F70726F746F6275662F656D7074792E70726F746F120F676F6F676C652E70726F746F62756622070A05456D70747942540A13636F6D2E676F6F676C652E70726F746F627566420A456D70747950726F746F50015A057479706573F80101A20203475042AA021E476F6F676C652E50726F746F6275662E57656C6C4B6E6F776E5479706573620670726F746F33"
        
    };
}


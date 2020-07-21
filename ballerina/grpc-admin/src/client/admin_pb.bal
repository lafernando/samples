import ballerina/grpc;

public type AdminServiceBlockingClient client object {

    *grpc:AbstractClientEndpoint;

    private grpc:Client grpcClient;

    public function init(string url, grpc:ClientConfiguration? config = ()) {
        // initialize client endpoint.
        self.grpcClient = new(url, config);
        checkpanic self.grpcClient.initStub(self, "blocking", ROOT_DESCRIPTOR, getDescriptorMap());
    }

    public remote function add(AddRequest req, grpc:Headers? headers = ()) returns ([AddResponse, grpc:Headers]|grpc:Error) {
        
        var payload = check self.grpcClient->blockingExecute("AdminService/add", req, headers);
        grpc:Headers resHeaders = new;
        anydata result = ();
        [result, resHeaders] = payload;
        
        return [<AddResponse>result, resHeaders];
        
    }

    public remote function multiply(MultiplyRequest req, grpc:Headers? headers = ()) returns ([MultiplyResponse, grpc:Headers]|grpc:Error) {
        
        var payload = check self.grpcClient->blockingExecute("AdminService/multiply", req, headers);
        grpc:Headers resHeaders = new;
        anydata result = ();
        [result, resHeaders] = payload;
        
        return [<MultiplyResponse>result, resHeaders];
        
    }

    public remote function addPerson(Person req, grpc:Headers? headers = ()) returns ([AddPersonResponse, grpc:Headers]|grpc:Error) {
        
        var payload = check self.grpcClient->blockingExecute("AdminService/addPerson", req, headers);
        grpc:Headers resHeaders = new;
        anydata result = ();
        [result, resHeaders] = payload;
        
        return [<AddPersonResponse>result, resHeaders];
        
    }

    public remote function getPerson(GetPersonRequest req, grpc:Headers? headers = ()) returns ([Person, grpc:Headers]|grpc:Error) {
        
        var payload = check self.grpcClient->blockingExecute("AdminService/getPerson", req, headers);
        grpc:Headers resHeaders = new;
        anydata result = ();
        [result, resHeaders] = payload;
        
        return [<Person>result, resHeaders];
        
    }

};

public type AdminServiceClient client object {

    *grpc:AbstractClientEndpoint;

    private grpc:Client grpcClient;

    public function init(string url, grpc:ClientConfiguration? config = ()) {
        // initialize client endpoint.
        self.grpcClient = new(url, config);
        checkpanic self.grpcClient.initStub(self, "non-blocking", ROOT_DESCRIPTOR, getDescriptorMap());
    }

    public remote function add(AddRequest req, service msgListener, grpc:Headers? headers = ()) returns (grpc:Error?) {
        
        return self.grpcClient->nonBlockingExecute("AdminService/add", req, msgListener, headers);
    }

    public remote function multiply(MultiplyRequest req, service msgListener, grpc:Headers? headers = ()) returns (grpc:Error?) {
        
        return self.grpcClient->nonBlockingExecute("AdminService/multiply", req, msgListener, headers);
    }

    public remote function addPerson(Person req, service msgListener, grpc:Headers? headers = ()) returns (grpc:Error?) {
        
        return self.grpcClient->nonBlockingExecute("AdminService/addPerson", req, msgListener, headers);
    }

    public remote function getPerson(GetPersonRequest req, service msgListener, grpc:Headers? headers = ()) returns (grpc:Error?) {
        
        return self.grpcClient->nonBlockingExecute("AdminService/getPerson", req, msgListener, headers);
    }

};

public type AddRequest record {|
    int[] numbers = [];
    
|};


public type MultiplyResponse record {|
    int result = 0;
    
|};


public type GetPersonRequest record {|
    string id = "";
    
|};


public type AddResponse record {|
    int result = 0;
    
|};


public type AddPersonResponse record {|
    string id = "";
    
|};


public type Person record {|
    string id = "";
    string name = "";
    int birthYear = 0;
    
|};


public type MultiplyRequest record {|
    int v1 = 0;
    int v2 = 0;
    
|};



const string ROOT_DESCRIPTOR = "0A0B61646D696E2E70726F746F224A0A06506572736F6E120E0A0269641801200128095202696412120A046E616D6518022001280952046E616D65121C0A09626972746859656172180320012805520962697274685965617222220A10476574506572736F6E52657175657374120E0A0269641801200128095202696422230A11416464506572736F6E526573706F6E7365120E0A0269641801200128095202696422260A0A4164645265717565737412180A076E756D6265727318012003280352076E756D6265727322250A0B416464526573706F6E736512160A06726573756C741801200128035206726573756C7422310A0F4D756C7469706C7952657175657374120E0A02763118012001280352027631120E0A02763218022001280352027632222A0A104D756C7469706C79526573706F6E736512160A06726573756C741801200128035206726573756C7432B4010A0C41646D696E5365727669636512200A03616464120B2E416464526571756573741A0C2E416464526573706F6E7365122F0A086D756C7469706C7912102E4D756C7469706C79526571756573741A112E4D756C7469706C79526573706F6E736512280A09616464506572736F6E12072E506572736F6E1A122E416464506572736F6E526573706F6E736512270A09676574506572736F6E12112E476574506572736F6E526571756573741A072E506572736F6E620670726F746F33";
function getDescriptorMap() returns map<string> {
    return {
        "admin.proto":"0A0B61646D696E2E70726F746F224A0A06506572736F6E120E0A0269641801200128095202696412120A046E616D6518022001280952046E616D65121C0A09626972746859656172180320012805520962697274685965617222220A10476574506572736F6E52657175657374120E0A0269641801200128095202696422230A11416464506572736F6E526573706F6E7365120E0A0269641801200128095202696422260A0A4164645265717565737412180A076E756D6265727318012003280352076E756D6265727322250A0B416464526573706F6E736512160A06726573756C741801200128035206726573756C7422310A0F4D756C7469706C7952657175657374120E0A02763118012001280352027631120E0A02763218022001280352027632222A0A104D756C7469706C79526573706F6E736512160A06726573756C741801200128035206726573756C7432B4010A0C41646D696E5365727669636512200A03616464120B2E416464526571756573741A0C2E416464526573706F6E7365122F0A086D756C7469706C7912102E4D756C7469706C79526571756573741A112E4D756C7469706C79526573706F6E736512280A09616464506572736F6E12072E506572736F6E1A122E416464506572736F6E526573706F6E736512270A09676574506572736F6E12112E476574506572736F6E526571756573741A072E506572736F6E620670726F746F33"
        
    };
}


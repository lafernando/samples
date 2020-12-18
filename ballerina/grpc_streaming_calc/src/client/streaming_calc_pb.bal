import ballerina/grpc;

public type StreamingCalcServiceClient client object {

    *grpc:AbstractClientEndpoint;

    private grpc:Client grpcClient;

    public function init(string url, grpc:ClientConfiguration? config = ()) {
        // initialize client endpoint.
        self.grpcClient = new(url, config);
        checkpanic self.grpcClient.initStub(self, "non-blocking", ROOT_DESCRIPTOR, getDescriptorMap());
    }

    public remote function add(service msgListener, grpc:Headers? headers = ()) returns (grpc:StreamingClient|grpc:Error) {
        return self.grpcClient->streamingExecute("StreamingCalcService/add", msgListener, headers);
    }
    public remote function incrementalAdd(service msgListener, grpc:Headers? headers = ()) returns (grpc:StreamingClient|grpc:Error) {
        return self.grpcClient->streamingExecute("StreamingCalcService/incrementalAdd", msgListener, headers);
    }
};


const string ROOT_DESCRIPTOR = "0A1473747265616D696E675F63616C632E70726F746F1A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F32A9010A1453747265616D696E6743616C635365727669636512410A03616464121B2E676F6F676C652E70726F746F6275662E496E74363456616C75651A1B2E676F6F676C652E70726F746F6275662E496E74363456616C75652801124E0A0E696E6372656D656E74616C416464121B2E676F6F676C652E70726F746F6275662E496E74363456616C75651A1B2E676F6F676C652E70726F746F6275662E496E74363456616C756528013001620670726F746F33";
function getDescriptorMap() returns map<string> {
    return {
        "streaming_calc.proto":"0A1473747265616D696E675F63616C632E70726F746F1A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F32A9010A1453747265616D696E6743616C635365727669636512410A03616464121B2E676F6F676C652E70726F746F6275662E496E74363456616C75651A1B2E676F6F676C652E70726F746F6275662E496E74363456616C75652801124E0A0E696E6372656D656E74616C416464121B2E676F6F676C652E70726F746F6275662E496E74363456616C75651A1B2E676F6F676C652E70726F746F6275662E496E74363456616C756528013001620670726F746F33",
        "google/protobuf/wrappers.proto":"0A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F120F676F6F676C652E70726F746F62756622230A0B446F75626C6556616C756512140A0576616C7565180120012801520576616C756522220A0A466C6F617456616C756512140A0576616C7565180120012802520576616C756522220A0A496E74363456616C756512140A0576616C7565180120012803520576616C756522230A0B55496E74363456616C756512140A0576616C7565180120012804520576616C756522220A0A496E74333256616C756512140A0576616C7565180120012805520576616C756522230A0B55496E74333256616C756512140A0576616C756518012001280D520576616C756522210A09426F6F6C56616C756512140A0576616C7565180120012808520576616C756522230A0B537472696E6756616C756512140A0576616C7565180120012809520576616C756522220A0A427974657356616C756512140A0576616C756518012001280C520576616C7565427C0A13636F6D2E676F6F676C652E70726F746F627566420D577261707065727350726F746F50015A2A6769746875622E636F6D2F676F6C616E672F70726F746F6275662F7074797065732F7772617070657273F80101A20203475042AA021E476F6F676C652E50726F746F6275662E57656C6C4B6E6F776E5479706573620670726F746F33"
        
    };
}


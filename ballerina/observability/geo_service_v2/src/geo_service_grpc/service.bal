import ballerina/grpc;
import ballerinax/java.jdbc;
import ballerina/http as _;

type Entry record {|
    float lat;
    float long;
    string src = "UNKNOWN";
    string address;
    string ref?;
|};

jdbc:Client dbClient = new ({
    url: "jdbc:mysql://localhost:3306/GEO_DB?serverTimezone=UTC",
    username: "root",
    password: "root"
});

listener grpc:Listener ep = new (8083);

service GeoService on ep {

    resource function lookup(grpc:Caller caller, LookupRequest value) returns @tainted error? {
        var rs = check dbClient->select("SELECT address FROM GEO_ENTRY WHERE lat = ? AND lng = ?", 
                                         record {string address;}, value.lat, value.long);
        LookupResponse resp;                                             
        if rs.hasNext() {
            string address = <@untainted> <string> rs.getNext()["address"];
            resp = { address };
            check caller->send(resp);
            check caller->complete();
        } else {
            resp = { address: "" };
            check caller->send(resp);
            check caller->complete();
        }
    }
    resource function store(grpc:Caller caller, StoreRequest value) returns error? {
        _ = check dbClient->update("INSERT INTO GEO_ENTRY (lat, lng, src, address, ref) VALUES (?,?,?,?,?)", 
                                    value.lat, value.long, value.src, value.address, value?.ref.toString());
        check caller->send({});
        check caller->complete();
    }
}

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


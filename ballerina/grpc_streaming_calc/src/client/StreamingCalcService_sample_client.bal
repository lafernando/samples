public function main (string... args) {

    StreamingCalcServiceClient ep = new("http://localhost:9090");

}

service StreamingCalcServiceMessageListener = service {

    resource function onMessage(string message) {
        // Implementation goes here.
    }

    resource function onError(error err) {
        // Implementation goes here.
    }

    resource function onComplete() {
        // Implementation goes here.
    }
};


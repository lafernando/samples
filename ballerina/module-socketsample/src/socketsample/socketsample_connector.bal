// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
import ballerina/socket;
import ballerina/lang.'string as strings;

# Object to initialize a TCP socket based client.
#
public type Client client object {

    socket:Client socket = new({ host: "localhost", port: 65000 });

    string authToken;

    public function __init(Configuration config) returns error? {
        string authStr = "AUTH\n" + config.username + "\n" + config.password + "\n";
        check self.writeFully(self.socket, authStr.toBytes());
        self.authToken = check strings:fromBytes(check self.readFully(self.socket, 4));
    }

    # Do the action.
    #
    # + input - The input
    # + return - The result of the action
    public remote function doAction(string input) returns string|error {
        // write all the bytes given
        string payload = self.authToken + "\n" + input;
        byte[] data = payload.toBytes();
        check self.writeFully(self.socket, data);
        int n = 4;
        // read n number of bytes
        byte[] readData = check self.readFully(self.socket, n);
        return check strings:fromBytes(readData);
    }

    function readFully(socket:Client socket, int length) returns byte[]|error {
        byte[] result = [];
        int remaining = length;
        while (remaining > 0) {
            //var [data, i] = check self.socket->read(remaining);    
            var x = check self.socket->read(remaining);    
            var [data, i] = x;
            remaining -= i;
            result.push(...data);
        }
        return result;
    }

    function writeFully(socket:Client socket, byte[] data) returns error? {
        int i = 0;
        while i < data.length() {
            int j = check self.socket->write(data.slice(i, data.length()));
            i += j;
        }
    }

};

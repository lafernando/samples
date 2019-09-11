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

# Object to initialize a TCP socket based client.
#
public type Client client object {

    socket:Client socket;
    string authToken;

    public function __init(Configuration config) returns error? {
        self.socket = new({ host: "localhost", port: 75000 });
        check self.writeFully(self.socket, "AUTH".toBytes());
        // populate the auth token after a security handshake (or something similar)
        self.authToken = "";
    }

    # Do the action.
    #
    # + action - The action to be done
    # + return - The result of the action
    public remote function doAction(string action) returns string|error {
        // write all the bytes given
        check self.writeFully(self.socket, "DATA".toBytes());
        int n = 10;
        // read n number of bytes
        byte[] readData = check self.readFully(self.socket, n);
        return "";
    }

    function readFully(socket:Client socket, int length) returns byte[]|error {
        byte[] result = [];
        int remaining = length;
        while (remaining > 0) {
            var [data, i] = check self.readSingle(socket, remaining);
            remaining -= i;
            result.push(...data);
        }
        return result;
    }

    function writeFully(socket:Client socket, byte[] data) returns error? {
        int i = 0;
        while i < data.length() {
            i += check self.writeSingle(socket, data.slice(i, data.length()));
        }
    }

    function writeSingle(socket:Client socket, byte[] data) returns int|error {
        return self.socket->write(data);
    }

    function readSingle(socket:Client socket, int length) returns @tainted ([byte[],int]|error) {
        return self.socket->read(length);
    }

};


import ballerinax/awslambda;
import ballerina/system;

# Generate UUID.
#
# + input - input data
# + return - UUID string
@awslambda:Function
public function uuid(awslambda:Context ctx, json input) returns json|error {
    return system:uuid();
}
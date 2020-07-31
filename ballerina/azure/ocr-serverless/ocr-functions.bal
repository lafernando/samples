import ballerinax/azure.functions as af;

@af:Function
function submitImage(af:Context ctx, 
                     @af:HTTPTrigger { authLevel: "anonymous", route: "submit/{email}" } af:HTTPRequest req, 
                     @af:BlobOutput { path: "images/{headers.X-ARR-LOG-ID}" } af:StringOutputBinding blob,
                     @af:QueueOutput { queueName: "requests" } af:StringOutputBinding requestQueue)
                     returns @af:HTTPOutput string {
    map<json> headers = <map<json>> ctx.metadata.Headers;
    string jobId = headers["X-ARR-LOG-ID"].toString();
    string email = <string> ctx.metadata.email.toString().fromJsonString();
    blob.value = req.body;
    json queueEntry = { jobId, email };
    requestQueue.value = queueEntry.toJsonString();
    return queueEntry.toJsonString();
}


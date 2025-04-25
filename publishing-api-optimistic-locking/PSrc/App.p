
event eRequest: tRequest;
event eResponse: tResponse;

enum tResponseStatus {
    SUCCESS,
    CONFLICT,
    TIMEOUT
}

type tRequest = (editionId: int, previousVersion: int, client: Client);
type tResponse = (editionId: int, previousVersion: int, currentVersion: int, status: tResponseStatus);

machine App
{
    var editionVersions: map[int, int];
    var i: int;
    start state Init
    {
        entry (numEditions: int) {
            i = 0;
            while (i < numEditions) {
                editionVersions[i] = 0;
                i = i + 1;
            }    
            goto WaitForRequests;
        }
    }

    state WaitForRequests {
        on eRequest do (request: tRequest) {
            // Maybe return a response, or maybe timeout
            if ($) {
                if (!(request.editionId in editionVersions) || !(request.previousVersion < editionVersions[request.editionId])) {
                    editionVersions[request.editionId] = request.previousVersion + 1;
                    send request.client, eResponse, (editionId = request.editionId, previousVersion = request.previousVersion, currentVersion = editionVersions[request.editionId], status = SUCCESS);
                } else {
                    send request.client, eResponse, (editionId = request.editionId, previousVersion = request.previousVersion, currentVersion = editionVersions[request.editionId], status = CONFLICT);
                }
            } else {
                // Maybe process the request and time out, maybe just timeout
                if ($) {
                    if (!(request.editionId in editionVersions) || !(request.previousVersion < editionVersions[request.editionId])) {
                        editionVersions[request.editionId] = request.previousVersion + 1;
                    }
                }
                send request.client, eResponse, (editionId = request.editionId, previousVersion = request.previousVersion, currentVersion = editionVersions[request.editionId], status = TIMEOUT);
            }
        }
    }
}
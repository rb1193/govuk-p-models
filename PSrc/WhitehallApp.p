
event eLeaseRequestReceived: tLeaseRequest;
event eLeaseRequestResponse: tLeaseResponse;
event eWriteRequestReceived: tWriteRequest;
event eWriteRequestResponse: tWriteResponse;

enum tResponseStatus {
    SUCCESS,
    ERROR,
    TIMEOUT
}

type tLeaseRequest = (editionId: int, userId: int, client: Client);
type tLeaseResponse = (editionId: int, userId: int, status: tResponseStatus);
type tWriteRequest = (editionId: int, userId: int, client: Client);
type tWriteResponse = (editionId: int, userId: int, status: tResponseStatus);

machine WhitehallApp
{
    var leases: map[int, int];
    var timers: map[int, Timer];
    start state Init
    {
        entry {
            goto WaitForRequests;
        }
    }

    state WaitForRequests {
        on eLeaseRequestReceived do (request: tLeaseRequest) {
            if(request.editionId in leases && leases[request.editionId] != request.userId) {
                send request.client, eLeaseRequestResponse, (editionId = request.editionId, userId = request.userId, status = ERROR);
            } else {                
                if ($) {
                    leases[request.editionId] = request.userId;
                    timers[request.editionId] = CreateTimer(this, request.editionId);
                    announce eWhitehallLeaseGranted, request.editionId;
                    send request.client, eLeaseRequestResponse, (editionId = request.editionId, userId = request.userId, status = SUCCESS);
                } else {
                    if ($) {
                        leases[request.editionId] = request.userId;
                        timers[request.editionId] = CreateTimer(this, request.editionId);
                        announce eWhitehallLeaseGranted, request.editionId;
                    }
                    send request.client, eLeaseRequestResponse, (editionId = request.editionId, userId = request.userId, status = TIMEOUT);
                }
            }
        }

        on eWriteRequestReceived do (request: tWriteRequest) {
            if(request.editionId in leases) {
                if(leases[request.editionId] == request.userId) {
                    if ($) {
                        leases -= request.editionId;
                        CancelTimer(timers[request.editionId]);
                        timers -= request.editionId;
                        announce eWhitehallLeaseReleased, request.editionId;
                        send request.client, eWriteRequestResponse, (editionId = request.editionId, userId = request.userId, status = SUCCESS);
                    } else {
                        if ($) {
                            leases -= request.editionId;
                            CancelTimer(timers[request.editionId]);
                            timers -= request.editionId;
                            announce eWhitehallLeaseReleased, request.editionId;
                        }
                        send request.client, eWriteRequestResponse, (editionId = request.editionId, userId = request.userId, status = TIMEOUT);
                    }
                } else {
                    send request.client, eWriteRequestResponse, (editionId = request.editionId, userId = request.userId, status = ERROR);
                }
            } else {
                send request.client, eWriteRequestResponse, (editionId = request.editionId, userId = request.userId, status = ERROR);
            }
        }

        on eTimeOut do (editionId: int) {
            leases -= editionId;
            timers -= editionId;
            announce eWhitehallLeaseTimedOut, editionId;
        }
    }
}
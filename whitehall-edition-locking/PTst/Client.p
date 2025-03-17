machine Client {
    var app: WhitehallApp;
    var editionIds: set[int];
    var userId: int;
    var numTransactions: int;
    var processedTransactions: int;
    start state Init {
        entry (payload: (app: WhitehallApp, userId: int, editionIds: set[int],  numTransactions: int)) {
            app = payload.app;
            editionIds = payload.editionIds;
            userId = payload.userId;
            numTransactions = payload.numTransactions;
            processedTransactions = 0;
            goto SendLeaseRequest, choose(editionIds);
        }
    }

    state SendLeaseRequest {
        entry (editionId: int) {
            if (processedTransactions < numTransactions) {            
                send app, eLeaseRequestReceived, (editionId = editionId, userId = userId, client = this);
            } else {
                // All transactions processed
                raise halt;
            }
        }
        on eLeaseRequestResponse do (response: tLeaseResponse) {
            if (response.status == SUCCESS) {
                goto SendWriteRequest, response.editionId;
            } else {
                goto SendLeaseRequest, response.editionId;
            }
        }
    }

    state SendWriteRequest {
        entry (editionId: int) {
            send app, eWriteRequestReceived, (editionId = editionId, userId = userId, client = this);
        }
        on eWriteRequestResponse do (response: tWriteResponse) {
            if (response.status == SUCCESS) {
                processedTransactions = processedTransactions + 1;
                goto SendLeaseRequest, choose(editionIds);
            }
            if (response.status == ERROR) {
                goto SendLeaseRequest, choose(editionIds);
            }
            goto SendWriteRequest, response.editionId;
        }
    }
}
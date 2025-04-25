machine Client {
    var app: App;
    var numEditions: int;
    var numVersions: int;
    var editionVersions: map[int,int];
    var i: int;
    start state Init {
        entry (payload: (app: App, numEditions: int, numVersions: int)) {
            app = payload.app;
            numEditions = payload.numEditions;
            numVersions = payload.numVersions;
            i = 0;
            while (i < numEditions) {
                editionVersions[i] = 0;
                i = i + 1;
            }
            goto SendRequest, choose(keys(editionVersions));
        }
    }

    state SendRequest {
        entry (editionId: int) {
            send app, eRequest, (editionId = editionId, previousVersion = editionVersions[editionId], client = this);
            goto WaitForResponses;
        }
    }

    state WaitForResponses {
        on eResponse do (response: tResponse) {
            if (response.status == SUCCESS || response.status == CONFLICT) {
                editionVersions[response.editionId] = response.currentVersion;
                if (response.currentVersion == numVersions) {
                    editionVersions -= response.editionId;
                }
                if (sizeof(editionVersions) == 0) {
                    raise halt;
                }
                goto SendRequest, choose(keys(editionVersions));
            } else {
                goto SendRequest, response.editionId;
            }
        }
    }
}
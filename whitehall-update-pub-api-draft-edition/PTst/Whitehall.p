enum tResponseStatus {
    SUCCESS,
    ERROR,
    TIMEOUT
}

event eWhitehallOpenDatabaseTransactionRequest: Whitehall;
event eWhitehallOpenDatabaseTransactionResponse;
event eWhitehallUpdateDatabaseRequest: Whitehall;
event eWhitehallUpdateDatabaseResponse;
event eWhitehallCommitDatabaseTransactionRequest: Whitehall;
event eWhitehallCommitDatabaseTransactionResponse;
event eWhitehallRollbackDatabaseTransactionRequest: Whitehall;
event eWhitehallRollbackDatabaseTransactionResponse;
event ePublishingApiRequest: Whitehall;
event ePublishingApiResponse: tResponseStatus;

machine Whitehall {
    var database: WhitehallDatabase;
    var publishingApi: PublishingApi;
    start state Init {
        entry (deps : (database: WhitehallDatabase, publishingApi: PublishingApi)) {
            database = deps.database;
            publishingApi = deps.publishingApi;
            goto OpenTransaction;
        }
    }

    state OpenTransaction {
        entry {
            send database, eWhitehallOpenDatabaseTransactionRequest, this;
        }
        on eWhitehallOpenDatabaseTransactionResponse goto PerformUpdates;
    }
    
    state PerformUpdates {
        entry {
            send database, eWhitehallUpdateDatabaseRequest, this;
            receive { 
                case eWhitehallUpdateDatabaseResponse: {}
            }
            send publishingApi, ePublishingApiRequest, this;
            goto WaitForPublishingApiResponse;
        }
    }

    state WaitForPublishingApiResponse {
        on ePublishingApiResponse do (response: tResponseStatus) {
            if (response == SUCCESS) {
                send database, eWhitehallCommitDatabaseTransactionRequest, this;
            } else {
                send database, eWhitehallRollbackDatabaseTransactionRequest, this;
            }
            goto WaitForTransactionCompletion;
        }
    }

    state WaitForTransactionCompletion {
        ignore eWhitehallCommitDatabaseTransactionResponse;
        ignore eWhitehallRollbackDatabaseTransactionResponse;
    }
}
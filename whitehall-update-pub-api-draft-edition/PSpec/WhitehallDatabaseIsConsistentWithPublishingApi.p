spec WhitehallDatabaseIsConsistentWithPublishingApi observes eWhitehallOpenDatabaseTransactionResponse, eWhitehallUpdateDatabaseResponse, ePublishingApiResponse, eWhitehallCommitDatabaseTransactionResponse, eWhitehallRollbackDatabaseTransactionResponse {
    var transactionStarted: bool;
    var whitehallDbValue: int;
    var publishingApiValue: int;
    start state Init {
        entry {
            transactionStarted = false;
            whitehallDbValue = 0;
            publishingApiValue = 0;
            goto WaitForTransactionStart;
        }
    }

    state WaitForTransactionStart {
        on eWhitehallOpenDatabaseTransactionResponse do {
            transactionStarted = true;
            goto WaitForUpdates;        
        }
    }

    state WaitForUpdates {
        on eWhitehallUpdateDatabaseResponse do {
            whitehallDbValue = 1;
        }

        on ePublishingApiResponse do (res: tResponseStatus) {
            if (res == SUCCESS) {
                publishingApiValue = 1;
            }
        }

        on eWhitehallCommitDatabaseTransactionResponse goto TransactionComplete;
        on eWhitehallRollbackDatabaseTransactionResponse goto TransactionComplete;
    }

    state TransactionComplete {
        entry {
            assert whitehallDbValue == publishingApiValue, format("Whitehall DB value and Publishing API value do not match");
        }
    }
}

spec AllRequestsProcessed observes eWhitehallOpenDatabaseTransactionResponse, eWhitehallCommitDatabaseTransactionResponse, eWhitehallRollbackDatabaseTransactionResponse {
    start cold state AllTransactionsClosed {
        on eWhitehallOpenDatabaseTransactionResponse goto TransactionOpen;
    }

    hot state TransactionOpen {
        on eWhitehallCommitDatabaseTransactionResponse goto AllTransactionsClosed;
        on eWhitehallRollbackDatabaseTransactionResponse goto AllTransactionsClosed;
    }
}
